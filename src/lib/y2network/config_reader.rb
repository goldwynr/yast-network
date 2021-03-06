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
module Y2Network
  module ConfigReader
    # Config reader for a given source
    #
    # @param source [Symbol] Source name (e.g., :sysconfig)
    # @param opts  [Array<Object>] Reader options
    # @return [Y2Network::Autoinst::ConfigReader,Y2Network::Sysconfig::ConfigReader]
    def self.for(source, *opts)
      require "y2network/#{source}/config_reader"
      modname = source.to_s.split("_").map(&:capitalize).join
      klass = Y2Network.const_get("#{modname}::ConfigReader")
      klass.new(*opts)
    end
  end
end
