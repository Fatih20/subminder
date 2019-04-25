//                                         
//   _____     _   _____ _       _         
//  |   __|_ _| |_|     |_|___ _| |___ ___ 
//  |__   | | | . | | | | |   | . | -_|  _|
//  |_____|___|___|_|_|_|_|_|_|___|___|_|  
//                                         
//                            Version 1.1.0
//  
//        Jeremy Vaartjes<jeremy@vaartj.es>
//  
//  =======================================
//  
//  Copyright (C) 2019 Jeremy Vaartjes
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//  
//  =======================================
//  

public class DefaultCurrencyDialog : Gtk.Dialog {
    SubMinder rootApp;
    SMCurrency currency;
    Gtk.ComboBox currencyView;
    Gtk.ListStore currencyListStore;

    public DefaultCurrencyDialog(SubMinder *appObj, SMCurrency *currencyObj){
        rootApp = appObj;
        currency = currencyObj;
        this.deletable = false;
        this.modal = true;
        title = _("Set Default Currency");
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        type_hint = Gdk.WindowTypeHint.DIALOG;

        var setButton = new Gtk.Button.with_label (_("Set Currency"));
        setButton.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        setButton.clicked.connect (saveDialog);

        currencyListStore = new Gtk.ListStore (1, typeof (string));
        currencyView = new Gtk.ComboBox.with_model (currencyListStore);
        var counter = 0;
        foreach (var entry in currency.currencies.entries) {
            Gtk.TreeIter iter;
            currencyListStore.append (out iter);
            currencyListStore.set (iter, 0, entry.key + " - " + entry.value);
            if(entry.key == rootApp.settings.default_currency){
                currencyView.active = counter;
            }
            counter++;
        }
        if(rootApp.settings.default_currency == "UNSET"){
            currencyView.active = 0;
        }
        Gtk.CellRendererText currencyViewRenderer = new Gtk.CellRendererText ();
        currencyView.pack_start (currencyViewRenderer, true);
        currencyView.add_attribute (currencyViewRenderer, "text", 0);

        var title = new Gtk.Label(_("Choose a default currency"));
        title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var grid = new Gtk.Grid ();
        grid.row_spacing = 12;
        grid.column_spacing = 12;
        grid.margin_start = 12;
        grid.margin_end = 12;
        grid.attach (title, 0, 0, 1, 1);
        grid.attach (currencyView, 0, 1, 1, 1);
        grid.attach (setButton, 0, 2, 1, 1);

        ((Gtk.Container)get_content_area ()).add (grid);
    }

    private void saveDialog () {
        Gtk.TreeIter iter;
        currencyView.get_active_iter(out iter);
        string selectedStr = "";
        currencyListStore.get(iter, 0, &selectedStr);
        foreach (var entry in currency.currencies.entries) {
            if(entry.key + " - " + entry.value == selectedStr){
                rootApp.settings.default_currency = entry.key;
                rootApp.updateHeader();
            }
        }
        rootApp.defaultCurrencyButton.label = rootApp.settings.default_currency;
        this.destroy ();
    }
}
