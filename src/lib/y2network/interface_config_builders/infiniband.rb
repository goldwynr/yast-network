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
require "y2network/interface_config_builder"
require "y2network/ipoib_mode"

module Y2Network
  module InterfaceConfigBuilders
    class Infiniband < InterfaceConfigBuilder
      def initialize(config: nil)
        super(type: InterfaceType::INFINIBAND, config: config)
      end

      # @param value [String] ipoib mode configuration
      def ipoib_mode=(value)
        value = "" if value == "default"
        connection_config.ipoib_mode = IpoibMode.from_name(value)
      end

      # Returns current value of infiniband mode
      #
      # @return [String] particular mode or "default" when not set
      def ipoib_mode
        return "default" if connection_config.ipoib_mode.name == ""

        connection_config.ipoib_mode.name
      end
    end
  end
end
