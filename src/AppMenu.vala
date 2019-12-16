using Gtk;
using Gdk;
using GLib.Math;
using Json;

/*
* AppMenu
* Author: David Mohammed
* Copyright © 2017-2019 Ubuntu Budgie Developers
* Website=https://ubuntubudgie.org
* This program is free software: you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation, either version 3 of the License, or any later version.
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details. You should have received a copy of the GNU General Public
* License along with this program.  If not, see
* <https://www.gnu.org/licenses/>.
*/

namespace SupportingFunctions {
    /* 
    * Here we keep the (possibly) shared stuff, or general functions, to
    * keep the main code clean and readable
    */
}


namespace AppMenuApplet { 

    public class AppMenuSettings : Gtk.Grid {
        /* Budgie Settings -section */
        GLib.Settings? settings = null;

        public AppMenuSettings(GLib.Settings? settings) {
            /*
            * Gtk stuff, widgets etc. here 
            */
        }
    }


    public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
        public Budgie.Applet get_panel_widget(string uuid) {
            return new Applet(uuid);
        }
    }


    public class AppMenuPopover : Budgie.Popover {
        private Gtk.EventBox indicatorBox;
        /* process stuff */
        /* GUI stuff */
        private Gtk.Grid? indicator_grid = null;
        
        /* misc stuff */

        public AppMenuPopover(Gtk.EventBox indicatorBox, Slingshot.SlingshotView view) {
            GLib.Object(relative_to: indicatorBox);
            
            /* gsettings stuff */

            /* grid */
            //var indicator_label = new Gtk.Label (_("Applications"));
            //indicator_label.vexpand = true;

            //var indicator_icon = new Gtk.Image.from_icon_name ("system-search-symbolic", Gtk.IconSize.MENU);

            indicator_grid = new Gtk.Grid ();
            //indicator_grid.attach (indicator_icon, 0, 0, 1, 1);
            //indicator_grid.attach (indicator_label, 1, 0, 1, 1);
            
            //this.maingrid = new Gtk.Grid();
            //this.add(this.maingrid);
            indicator_grid.attach (view, 0, 1, 1, 1);
            this.add(indicator_grid);
        }
    }


    public class Applet : Budgie.Applet {

        private Gtk.EventBox indicatorBox;
        private AppMenuPopover popover = null;
        private unowned Budgie.PopoverManager? manager = null;
        public string uuid { public set; public get; }

        private const string KEYBINDING_SCHEMA = "org.gnome.desktop.wm.keybindings";

        private Slingshot.DBusService? dbus_service = null;
        private Slingshot.SlingshotView? view = null;

        private static GLib.Settings? keybinding_settings;
        private weak Gtk.IconTheme default_theme = null; 

        protected GLib.Settings settings;

        Gtk.Image img;
        int pixel_size = 32;

        /* specifically to the settings section */
        /*public override bool supports_settings()
        {
            return true;
        }
        public override Gtk.Widget? get_settings_ui()
        {
            return new AppMenuSettings(this.get_applet_settings(uuid));
        }*/

        public Applet(string uuid) {
            initialiseLocaleLanguageSupport();
            if (SettingsSchemaSource.get_default ().lookup (KEYBINDING_SCHEMA, true) != null) {
                keybinding_settings = new GLib.Settings (KEYBINDING_SCHEMA);
            }

            GLib.Object(uuid: uuid);

            settings_schema = "com.solus-project.budgie-menu";
            settings_prefix = "/com/solus-project/budgie-panel/instance/budgie-menu";

            settings = this.get_applet_settings(uuid);

            settings.changed.connect(on_settings_changed);

            default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/io/elementary/desktop/wingpanel/applications-menu/icons");

            if (view == null) {
                view = new Slingshot.SlingshotView ();

#if HAS_PLANK
                unowned Plank.Unity client = Plank.Unity.get_default ();
                client.add_client (view);
#endif

                //view.close_indicator.connect (on_close_indicator);

                if (dbus_service == null) {
                    dbus_service = new Slingshot.DBusService (view);
                }
            }

            /* box */
            indicatorBox = new Gtk.EventBox();
            img = new Gtk.Image.from_icon_name("view-grid-symbolic", Gtk.IconSize.INVALID);
            img.pixel_size = pixel_size;
            img.no_show_all = true;
            /* set icon */
            indicatorBox.add(img);

            add(indicatorBox);
            /* Popover */
            popover = new AppMenuPopover(indicatorBox, view);

            //update_tooltip ();
            if (keybinding_settings != null) {
                keybinding_settings.changed.connect ((key) => {
                    if (key == "panel-main-menu") {
                        //update_tooltip ();
                    }
                });
            }

            supported_actions = Budgie.PanelAction.MENU;

            /* On Press indicatorBox */
            indicatorBox.button_press_event.connect((e)=> {
                if (e.button != 1) {
                    return Gdk.EVENT_PROPAGATE;
                }
                if (popover.get_visible()) {
                    popover.hide();
                } else {
                    view.show_slingshot ();
                    this.manager.show_popover(indicatorBox);
                }
                return Gdk.EVENT_STOP;
            });
            popover.get_child().show_all();
            show_all();

            on_settings_changed("menu-icon");
        }


        protected void on_settings_changed(string key) {
            bool should_show = true;

            switch (key)
            {
                case "menu-icon":
                    string? icon = settings.get_string(key);
                    if ("/" in icon) {
                        try {
                            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file(icon);
                            img.set_from_pixbuf(pixbuf.scale_simple(this.pixel_size, this.pixel_size, Gdk.InterpType.BILINEAR));
                        } catch (Error e) {
                            warning("Failed to update Budgie Menu applet icon: %s", e.message);
                            img.set_from_icon_name("view-grid-symbolic", Gtk.IconSize.INVALID); // Revert to view-grid-symbolic
                        }
                    } else if (icon == "") {
                        should_show = false;
                    } else {
                        img.set_from_icon_name(icon, Gtk.IconSize.INVALID);
                    }
                    img.set_pixel_size(this.pixel_size);
                    img.set_visible(should_show);
                    break;
                default:
                    break;
            }
        }

        public override void invoke_action(Budgie.PanelAction action) {
            if ((action & Budgie.PanelAction.MENU) != 0) {
                if (popover.get_visible()) {
                    popover.hide();
                } else {
                    view.show_slingshot();
                    this.manager.show_popover(indicatorBox);
                }
            }
        }

        /*private void update_tooltip () {
            string[] accels = {};

            if (keybinding_settings != null && indicator_grid != null) {
                var raw_accels = keybinding_settings.get_strv ("panel-main-menu");
                foreach (unowned string raw_accel in raw_accels) {
                    if (raw_accel != "") accels += raw_accel;
                }
            }

            indicator_grid.tooltip_markup = Granite.markup_accel_tooltip (accels, _("Open and search apps"));
        }*/

        public override void update_popovers(Budgie.PopoverManager? manager)
        {
            this.manager = manager;
            manager.register_popover(indicatorBox, popover);
        }

        public void initialiseLocaleLanguageSupport(){
            // Initialize gettext
            /*GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
            GLib.Intl.bindtextdomain(
                Config.GETTEXT_PACKAGE, Config.PACKAGE_LOCALEDIR
            );
            GLib.Intl.bind_textdomain_codeset(
                Config.GETTEXT_PACKAGE, "UTF-8"
            );
            GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);*/
        }
    }
}


[ModuleInit]
public void peas_register_types(TypeModule module){
    /* boilerplate - all modules need this */
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(
        Budgie.Plugin), typeof(AppMenuApplet.Plugin)
    );
}