# Copyright (c) [2019] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "yast"
require "cwm/table"
require "y2network/presenters/interface_summary"

Yast.import "NetworkService"
Yast.import "Lan"
Yast.import "Popup"
Yast.import "UI"

module Y2Network
  module Widgets
    class InterfacesTable < CWM::Table
      def initialize(description)
        textdomain "network"

        @description = description
      end

      def header
        [
          _("Name"),
          _("IP Address"),
          _("Device"),
          _("Note")
        ]
      end

      def opt
        [:notify, :immediate]
      end

      def handle
        @description.value = create_description

        nil
      end

      def items
        config = Yast::Lan.yast_config
        config.interfaces.map do |interface|
          conn = config.connections.by_name(interface.name)
          [
            interface.name, # first is ID in table
            friendly_name(interface),
            interface_protocol(conn),
            interface.name,
            note(interface, conn, config)
          ]
        end
      end

      # Workaround for usage in old CWM which also cache content of cwm items
      def init
        if Yast::NetworkService.is_network_manager
          Yast::Popup.Warning(
            _(
              "Network is currently handled by NetworkManager\n" \
              "or completely disabled. YaST is unable to configure some options."
            )
          )
          # switch to global tab
          Yast::UI.FakeUserInput("ID" => "global")
          return
        end

        change_items(items)
        handle
      end

    private

      def note(interface, conn, config)
        if interface.name != interface.old_name && interface.old_name
          return format("%s -> %s", interface.old_name, interface.name)
        end

        return "" unless conn

        master = conn.find_master(config.connections)
        return format(_("enslaved in %s"), master.name) if master

        return format(_("parent: %s"), conn.parent_device) if conn.type.vlan?

        ""
      end

      def interface_protocol(connection)
        return _("Not configured") if connection.nil?

        bootproto = connection.bootproto.name

        if bootproto == "static"
          ip_config = connection.ip
          ip_config ? ip_config.address.to_s : ""
        else
          bootproto.upcase
        end
      end

      def create_description
        config = Yast::Lan.yast_config
        Presenters::InterfaceSummary.new(value, config).text
      end

      # Returns a friendly name for a given interface
      #
      # @param interface [Interface] Network interface
      # @return [String] Friendly name for the interface (description or name)
      def friendly_name(interface)
        hwinfo = interface.hardware
        (hwinfo&.present?) ? hwinfo.description : interface.name
      end
    end
  end
end
