/*
 * $Id: ui-core.c 229 2009-03-22 18:02:04Z jorgenpt $
 *
 */

#include <string.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <time.h>
#include <netinet/in.h>

#include <curses.h>

#include "channel.h"
#include "commands.h"
#include "event.h"
#include "packet.h"
#include "despotify.h" 
#include "session.h"
#include "sndqueue.h"
#include "ui.h"
#include "ui-help.h"
#include "ui-search.h"
#include "ui-player.h"
#include "ui-playlist.h"
#include "util.h"
#include "xml.h"

#define HEADER_H 5
#define COMMAND_H 4

/* windowing routines */
static void header_update (int);
static void bottomwin_update (int);
static void sig_winch_handler (int);

/* input handling */
static int gui_readline (int);

static WINDOW *header;
static WINDOW *mainwin;
static WINDOW *bottomwin;

/* command window stuff */
static char c_input[256];
static int c_input_len;

/* We need access to the connection for sending commands */
static SESSION *ctx;

/* Handle server pings */
static time_t last_ping;

/* Handle country code */
static char country[4];

/* Current song */
char *current_song = NULL;

struct scrlwin_entry
{
	int id;
	char *text;
	void *private;
	struct scrlwin_entry *next;
};

struct scrlwin_context
{
	WINDOW *win;
	int w, h;
	int state;
	int (*action) (struct scrlwin_entry *);
	int ent_id_selected;
	struct scrlwin_entry *entries;
};
static struct scrlwin_context *scrlwinctx;

/*
 * Initialize curses and some windows
 *
 */
void gui_init (void)
{
	int h;
	int w;

	signal (SIGINT, gui_finish);
	signal (SIGWINCH, sig_winch_handler);

	initscr ();
	start_color ();
	keypad (stdscr, TRUE);
	nonl ();
	cbreak ();
	noecho ();
	refresh ();

	getmaxyx (stdscr, h, w);

	header_update (1);
	bottomwin_update (1);

	mainwin = newwin (h - HEADER_H - COMMAND_H, w, HEADER_H, 0);
	box (mainwin, 0, 0);
	wrefresh (mainwin);

	/*
	   scrlwin_init(mainwin, w, h - HEADER_H - COMMAND_H);
	 */

	doupdate ();
}

int scrlwin_init (WINDOW * win, int w, int h)
{
	scrlwinctx = malloc (sizeof (*scrlwinctx));
	if (!scrlwinctx)
		return -1;

	scrlwinctx->entries = NULL;
	scrlwinctx->state = 0;
	scrlwinctx->win = win;	/* win-win situation, can't be bad */
	scrlwinctx->w = w;
	scrlwinctx->h = h;
	scrlwinctx->ent_id_selected = 0;

	return 0;
}

void scrlwin_free (void)
{
	if (scrlwinctx) {
		DSFYfree (scrlwinctx);
	}
}

struct scrlwin_entry *scrlwin_ent_new (char *text, void *private)
{
	struct scrlwin_entry *e;
	int id = 0;

	if ((e = scrlwinctx->entries) == NULL) {
		e = scrlwinctx->entries = malloc (sizeof (*e));
	}
	else {
		for (id++; e->next; e = e->next)
			id++;
		e->next = malloc (sizeof (*e));
		e = e->next;
	}

	e->text = strdup (text);
	e->private = private;
	e->id = id + 1;
	e->next = NULL;

	return NULL;
}

void scrlwin_ent_free (struct scrlwin_entry *die)
{
	struct scrlwin_entry *e = scrlwinctx->entries;

	if (e == die)
		scrlwinctx->entries = die->next;
	else {
		while (e->next != die)
			e = e->next;
		e->next = die->next;
	}

	DSFYfree (die->text);
	DSFYfree (die);
}

int scrlwin_action_play (struct scrlwin_entry *e)
{
	struct track *t = (struct track *) e->private;

	/*
	 * XXX
	 *
	 * Hook up with some kind of handler that jumpstarts
	 * the sound subsysteam (which in turn will call
	 * cmd_getsubstreams()) as soon as we get our hands
	 * on the AES key needed for decrypting the music.
	 *
	 * The handler (4th arg) is NULL (bug!) for now.
	 * 
	 */

	return cmd_aeskey (ctx, t->file_id, t->track_id, NULL, NULL);
}

/*
 * To allow the main event loop to refresh the GUI
 */
void gui_update_view (void)
{
	header_update (0);
	doupdate ();
}

/*
 * Shutdown curses
 *
 */
void gui_finish (int unused)
{
	(void) unused;		/* don't warn. */
	endwin ();
}




/*
 * Handle windowresizing gracefully
 * XXX - Don't do this in the signal handler!
 *
 */
void sig_winch_handler (int unused)
{
	struct winsize ws;

	(void) unused;		/* don't warn. */

	ioctl (0, TIOCGWINSZ, &ws);
	resizeterm (ws.ws_row, ws.ws_col);

	wresize (header, HEADER_H, ws.ws_col);
	wresize (mainwin, ws.ws_row - HEADER_H - COMMAND_H, ws.ws_col);
	wsetscrreg (mainwin, 1, ws.ws_row - HEADER_H - COMMAND_H - 2);
	wresize (bottomwin, COMMAND_H, ws.ws_col);
	mvwin (bottomwin, ws.ws_row - COMMAND_H, 0);

	header_update (1);

	wclear (mainwin);
	box (mainwin, 0, 0);
	wrefresh (mainwin);

	bottomwin_update (1);

	doupdate ();
}

void update_timer(snd_SESSION *p, int timeplayed)
{
  static int lasttime = 0; 
  int  h, w;

  (void)p; /* Quell warning about it being unused. */
  
  if(lasttime != timeplayed)
  {
      int x, y;

      /* Print seconds played */
      getmaxyx (stdscr, h, w);
      header_update(1);
      mvwprintw (header, 3, w - 44, "%d",timeplayed);

      /* Update song title as while we are at it */
      if(current_song != NULL)
	mvwprintw (header, 3, 2, "Playing: %s ",current_song);
      else
	mvwprintw (header, 3, 2, "Playing:  ");

      wrefresh (header);

      /* Reset the cursor to the input field, where it belongs. */
      getyx (bottomwin, x, y);
      wmove (bottomwin, x, y);
      wrefresh (bottomwin);

      lasttime = timeplayed;
  }
}

static void header_update (int redraw)
{
	int h, w, x, y;
	struct playlist *p;
	int playlists, playlists_loaded;

	getmaxyx (stdscr, h, w);
	if (!header) {
		header = newwin (HEADER_H, w, 0, 0);
		redraw = 1;
	}

	if (redraw) {
		werase (header);
		box (header, 0, 0);
	}

	playlists = playlists_loaded = 0;
	for (p = playlist_root(); p; p = p->next) {
		playlists++;
		if (p->flags & PLAYLIST_LOADED)
			playlists_loaded++;
	}

	for (p = playlist_root(); p; p = p->next)
		if (p->flags & PLAYLIST_SELECTED)
			break;

	wattron (header, A_BOLD);
	mvwprintw (header, 1, 2, "Playlists: %2d/%2d", playlists_loaded,
		   playlists);
	wattroff (header, A_BOLD);
	mvwprintw (header, 2, 2, "Playlist: %s",
		   p ? p->name : "<none>");

	if(current_song != NULL)
	  mvwprintw (header, 3, 2, "Playing: %s ",current_song);
	else
	  mvwprintw (header, 3, 2, "Playing:  ");

	mvwprintw (header, 3, w - 60, "Seconds played:");

	if (!ctx || ctx->ap_sock == -1) {
		wattron (header, A_BOLD);
		mvwprintw (header, 1, w - 60, "DISCONNECTED");
		wattroff (header, A_BOLD);
	}
	else {
		wattron (header, A_BOLD);
		mvwprintw (header, 1, w - 60, "Logged in as ");
		wattroff (header, A_BOLD);
		if (ctx)
			mvwprintw (header, 1, w - 46, "%.16s", ctx->username);

		wattron (header, A_BOLD);
		mvwaddstr (header, 1, w - 29, "on");
		wattroff (header, A_BOLD);
		if (ctx)
			mvwprintw (header, 1, w - 26, "%.25s",
				   ctx->server_host);

		wattron (header, A_BOLD);
		mvwprintw (header, 2, w - 60, "Country");
		wattroff (header, A_BOLD);
		if (ctx)
			mvwprintw (header, 2, w - 46, "%.4s", country);

		wattron (header, A_BOLD);
		mvwaddstr (header, 2, w - 39, "Last ping");
		wattroff (header, A_BOLD);
		if (ctx)
			mvwprintw (header, 2, w - 29, "%.24s",
				   last_ping ? ctime (&last_ping) : "???");
	}

	wrefresh (header);

        /* Reset the cursor to the input field, where it belongs. */
        getyx (bottomwin, x, y);
        wmove (bottomwin, x, y);
        wrefresh (bottomwin);
}

static void bottomwin_update (int redraw)
{
	int h, w;

	getmaxyx (stdscr, h, w);
	if (!bottomwin) {
		bottomwin = newwin (COMMAND_H, w, h - COMMAND_H, 0);
		idlok (bottomwin, TRUE);
		wsetscrreg (bottomwin, 1, COMMAND_H - 2);
		scrollok (bottomwin, TRUE);
	}

	if (redraw) {
		werase (bottomwin);
		box (bottomwin, 0, 0);
	}

	mvwaddstr (bottomwin, 0, 3,
		   "[ textconsole - 'help' is your friend ]");
	mvwaddstr (bottomwin, COMMAND_H - 1, w - 20, "[ despotify ]");
	wattron (bottomwin, A_BOLD);
	mvwaddstr (bottomwin, COMMAND_H - 2, 2, " >");
	wattroff (bottomwin, A_BOLD);
	mvwprintw (bottomwin, COMMAND_H - 2, 5, "%s", c_input);
	wrefresh (bottomwin);
}

int gui_action_handler (EVENT * e, enum ev_flags ev_kind)
{
	int ch, err = 0;

	if (ev_kind == EV_MSG) {
		if (e->msg->class == MSG_CLASS_APP) {
			switch (e->msg->msg) {
			case MSG_APP_EXIT:
				e->state = 2;
				event_mark_busy (e);
				break;

			case MSG_APP_DISCONNECTED:
				header_update (0);
				doupdate ();
				break;

			default:
				break;
			}
		}
		else if (e->msg->class == MSG_CLASS_GUI) {
			switch (e->msg->msg) {
			case MSG_GUI_SESSIONPTR:
				ctx = *(SESSION **) e->msg->data;
				if (e->state == 0)
					e->state = 1;

				break;

			case MSG_GUI_REFRESH:
				header_update (1);
				doupdate ();
				break;

			default:
				break;
			}
		}

		return 0;
	}

	switch (e->state) {
	case 0:
		/* Wait for MSG_GUI_SESSIONPTR */
		event_mark_idle (e);
		break;

	case 1:
		/* Handle terminal input */
		if (ev_kind == EV_FD) {
			ch = getch ();
			if ((err = gui_readline (ch)) != 0) {
				/* Exit.. */
				e->state++;

				event_msg_post (MSG_CLASS_APP, MSG_APP_EXIT,
						NULL);
				err = 0;
			}
			else
				event_mark_idle (e);
		}

		doupdate ();
		break;

	case 2:
		/* Exit.. */
		gui_finish (0);
		event_mark_done (e);
		break;
	}

	return err;
}

static int gui_readline (int ch)
{
	int i;

	if (ch == KEY_ENTER || ch == 0x0a || ch == 0x0d
			|| ch == 0x15 /* ^U */  || ch == 0x17 /* ^W */ ) {
		if (c_input_len == 0)
			return 0;

		/* Pass on input if not delete word/line */
		if (ch != 0x15 && ch != 0x17) {
			/* Call input handler */
			if (!strcmp (c_input, "quit")
					|| !strcmp (c_input, "exit"))
				return -1;
			else if (!strncmp (c_input, "search ", 7))
				gui_search (ctx, mainwin, c_input + 7);
			else if (!strcmp (c_input, "help"))
				gui_help (mainwin, c_input + 4);
			else if (!strncmp (c_input, "help", 5))
				gui_help (mainwin, c_input + 5);
			else if (!strncmp (c_input, "list", 4))
				gui_playlist (mainwin, c_input + 4);
			else if (!strncmp (c_input, "play", 4))
				gui_player (c_input);
			else if (!strncmp (c_input, "stop", 4))
				gui_player (c_input);
			else if (!strncmp (c_input, "pause", 5))
				gui_player (c_input);
		}

		/* Handle delete word */
		if (ch == 0x17) {
			i = c_input_len - 1;
			/* Ignore trailing space */
			while (i && c_input[i] == ' ')
				i--;
			/* Consume data until space is hit */
			while (i && c_input[i] != ' ')
				i--;
			/* Space out next word up until c_input_len */
			for (; i < c_input_len; i++)
				c_input[i] = ' ';

			bottomwin_update (0);
			/* Consume all space down to next non-space */
			for (i -= 1; i && c_input[i - 1] == ' '; i--);
			c_input_len = i;
			c_input[c_input_len] = 0;
		}
		else {
			/* Space out content */
			for (ch = 0; ch < c_input_len; ch++)
				c_input[ch] = ' ';
			bottomwin_update (0);
			/* Start over at position 0 */
			c_input[0] = c_input_len = 0;
		}
	}
	else if (ch == KEY_BACKSPACE || ch == 0x08 || ch == 0x7f) {
		if (c_input_len) {
			c_input[c_input_len - 1] = ' ';
			bottomwin_update (0);
			c_input[--c_input_len] = 0;
		}
	}
	else if (ch == 0x09 /* tab */ ) {

	}
	else if (c_input_len < (int) sizeof (c_input) - 2) {
		c_input[c_input_len++] = ch;
		c_input[c_input_len] = 0;
	}
	else
		return 0;

	bottomwin_update (0);

	return 0;
}

void app_packet_callback (SESSION * session,
			  int cmd, unsigned char *payload, int len)
{
	(void) session;		/* don't warn. */

#ifndef GUI
	return;
#endif

	switch (cmd) {
	case CMD_PING:{
			time_t t;

			memcpy (&t, payload, 4);
			last_ping = ntohl (t);
			gui_update_view ();
			break;
		}

	case CMD_COUNTRYCODE:{
			int i;

			for (i = 0; i < len && i < (int) sizeof (country) - 1;
					i++)
				country[i] = payload[i];

			country[i] = 0;
			gui_update_view ();
			break;
		}

	case CMD_PRODINFO:
		{
			char *foo = malloc (len + 1);
			memcpy (foo, payload, len);
			foo[len] = 0;
			DSFYDEBUG ("Product info is: %s\n", foo);
			if (!strstr (foo, "<type>premium</type>")) {
				event_msg_post (MSG_CLASS_APP,
						MSG_APP_NOTFAIRGAME, NULL);
			}
			DSFYfree (foo);
		}
		break;
	}
}
