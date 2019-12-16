zeitgeist_backend_source = []
if get_option('with-zeitgeist')
    zeitgeist_backend_source = [
        'synapse-core/relevancy-backend-zg.vala'
    ]
endif

sources = [
    'AppMenu.vala',
    'SlingshotView.vala',
    'Pixels.vala',

    'Backend/AppSystem.vala',
    'Backend/DBusService.vala',
    'Backend/App.vala',
    'Backend/RelevancyService.vala',
    'Backend/SynapseSearch.vala',

    'Views/CategoryView.vala',
    'Views/GridView.vala',
    'Views/SearchView.vala',

    'Widgets/AppButton.vala',
    'Widgets/AppContextMenu.vala',
    'Widgets/AppListBox.vala',
    'Widgets/AppListRow.vala',
    'Widgets/Switcher.vala',
    'Widgets/SearchItem.vala',
    'Widgets/Sidebar.vala',
    'Widgets/PageChecker.vala',

    'synapse-core/Actions/TerminalRunnerAction.vala',
    'synapse-core/Actions/RunnerAction.vala',
    'synapse-core/Actions/CommonAction.vala',
    'synapse-core/Actions/ClipboardCopyAction.vala',
    'synapse-core/Actions/BaseAction.vala',
    'synapse-core/Interfaces/ItemProvider.vala',
    'synapse-core/Interfaces/Configurable.vala',
    'synapse-core/Interfaces/Activatable.vala',
    'synapse-core/Interfaces/ActionProvider.vala',
    'synapse-core/Matches/UriMatch.vala',
    'synapse-core/Matches/TextMatch.vala',
    'synapse-core/Matches/SearchMatch.vala',
    'synapse-core/Matches/Match.vala',
    'synapse-core/Matches/DefaultMatch.vala',
    'synapse-core/Matches/ApplicationMatch.vala',
    'synapse-core/config-service.vala',
    'synapse-core/data-sink.vala',
    'synapse-core/dbus-service.vala',
    'synapse-core/desktop-file-service.vala',
    'synapse-core/query.vala',
    'synapse-core/relevancy-service.vala',
    'synapse-core/result-set.vala',
    'synapse-core/utils.vala',
    zeitgeist_backend_source,

    'synapse-plugins/calculator-plugin.vala',
    'synapse-plugins/command-plugin.vala',
    'synapse-plugins/desktop-file-plugin.vala',
    'synapse-plugins/link-plugin.vala',
    asresources
]

dependencies = [
    glib_dep,
    gobject_dep,
    gio_dep,
    gio_unix_dep,
    granite_dep,
    gee_dep,
    gtk_dep,
    json_glib_dep,
    zeitgeist_dep,
    libgnome_menu_dep,
    libsoup_dep,
    appstream_dep,
    plank_dep,
    budgie_dep,
    peas_dep,
]

wingpanel_indicatorsdir = join_paths(libdir, 'budgie-desktop', 'plugins', 'application-menu')

shared_module(
    meson.project_name(),
    sources,
    dependencies: dependencies,
    c_args : '-DGMENU_I_KNOW_THIS_IS_UNSTABLE',
    install: true,
    install_dir: wingpanel_indicatorsdir
)

install_data('AppMenu.plugin', install_dir: wingpanel_indicatorsdir)