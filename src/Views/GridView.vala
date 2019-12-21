/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 *           2011-2012 Giulio Collura
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

public class Slingshot.Widgets.Grid : Gtk.Grid {
    public signal void app_launched ();

    public Gtk.Stack stack { get; private set; }

    private struct Page {
        public uint rows;
        public uint columns;
        public int number;
    }

    private Gtk.Grid current_grid;
    private Gtk.Widget? focused_widget;
    private Gee.HashMap<int, Gtk.Grid> grids;
    private Page page;

    private int focused_column;
    private int focused_row;
    private uint current_row = 0;
    private uint current_col = 0;

    private static GLib.Settings settings { get; private set; default = null; }
    static construct {
        settings = new GLib.Settings ("io.elementary.desktop.wingpanel.applications-menu");
    }

    construct {
        page.rows = 3;
        page.columns = 5;
        page.number = 1;

        stack = new Gtk.Stack ();
        stack.expand = true;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        var page_switcher = new Widgets.Switcher ();
        page_switcher.set_stack (stack);

        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 24;
        margin_bottom = 12;
        add (stack);
        add (page_switcher);

        grids = new Gee.HashMap<int, Gtk.Grid> (null, null);
        create_new_grid ();
        go_to_number (1);
    }

    public void populate (Backend.AppSystem app_system) {
        foreach (Gtk.Grid grid in grids.values) {
            grid.destroy ();
        }

        grids.clear ();

        page.rows = settings.get_int("rows");
        page.columns = settings.get_int("columns");

        current_row = 0;
        current_col = 0;
        page.number = 1;
        create_new_grid ();
        stack.set_visible_child (current_grid);

        foreach (Backend.App app in app_system.get_apps_by_name ()) {
            var app_button = new Widgets.AppButton (app);
            app_button.app_launched.connect (() => app_launched ());

            if (current_col == page.columns) {
                current_col = 0;
                current_row++;
            }

            if (current_row == page.rows) {
                page.number++;
                create_new_grid ();
                current_row = 0;
            }

            current_grid.get_child_at ((int)current_col, (int)current_row).destroy ();
            current_grid.attach (app_button, (int)current_col, (int)current_row, 1, 1);
            current_col++;
            current_grid.show ();
        }

        show_all ();
    }

    private void create_new_grid () {
        // Grid properties
        current_grid = new Gtk.Grid ();
        current_grid.expand = true;
        current_grid.row_homogeneous = true;
        current_grid.column_homogeneous = true;
        current_grid.margin_start = 12;
        current_grid.margin_end = 12;

        current_grid.row_spacing = 24;
        current_grid.column_spacing = 0;
        grids.set (page.number, current_grid);
        stack.add_titled (current_grid, page.number.to_string (), page.number.to_string ());

        // Fake grids in case there are not enough apps to fill the grid
        for (var row = 0; row < page.rows; row++)
            for (var column = 0; column < page.columns; column++)
                current_grid.attach (new Gtk.Grid (), column, row, 1, 1);
    }

    private Gtk.Widget? get_child_at (int column, int row) {
        var col = ((int)(column / page.columns)) + 1;

        var grid = grids.get (col);
        if (grid != null) {
            return grid.get_child_at (column - (int)page.columns * (col - 1), row) as Widgets.AppButton;
        } else {
            return null;
        }
    }

    public int get_page_columns () {
        return (int) page.columns;
    }

    public int get_n_pages () {
        return (int) page.number;
    }

    public int get_current_page () {
        return int.parse (stack.get_visible_child_name ());
    }

    public void go_to_next () {
        int page_number = get_current_page () + 1;
        if (page_number <= get_n_pages ())
            stack.set_visible_child_name (page_number.to_string ());
    }

    public void go_to_previous () {
        int page_number = get_current_page () - 1;
        if (page_number > 0)
            stack.set_visible_child_name (page_number.to_string ());
    }

    public void go_to_last () {
        stack.set_visible_child_name (get_n_pages ().to_string ());
    }

    public void go_to_number (int number) {
        stack.set_visible_child_name (number.to_string ());
    }

    public bool set_focus (int column, int row) {
        var target_widget = get_child_at (column, row);

        if (target_widget != null) {
            go_to_number (((int) (column / page.columns)) + 1);

            focused_column = column;
            focused_row = row;
            focused_widget = target_widget;

            focused_widget.grab_focus ();

            return true;
        }

        return false;
    }

    private bool set_paginated_focus (int column, int row) {
        int first_column = (get_current_page () - 1) * get_page_columns ();
        return set_focus (first_column, 0);
    }

    public bool set_focus_relative (int delta_column, int delta_row) {
        return set_focus (focused_column + delta_column, focused_row + delta_row);
    }

    public void top_left_focus () {
        set_paginated_focus (0, 0);
    }
}
