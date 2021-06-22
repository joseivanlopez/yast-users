# Copyright (c) [2021] SUSE LLC
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

require "y2issues"

module Y2Users
  # Internal class to validate the ids.
  # This is not part of the stable API.
  class IdsValidator
    include Yast::I18n

    # Issue location describing the Group#gid attribute
    GROUP_LOC = "group:gid".freeze
    # Issue location describing the User#uid attribute
    USER_LOC = "user:uid".freeze
    private_constant :GROUP_LOC, :USER_LOC

    # Constructor
    #
    # @param config [Y2Users::Config] config to detect colliding ids
    def initialize(config)
      textdomain "users"
      @config = config
    end

    # Returns a list of issues found while checking collisions
    #
    # @return [Y2Issues::List]
    def issues
      list = Y2Issues::List.new

      list.concat(duplicite_users)
      list.concat(duplicite_groups)

      list
    end

  private

    # @return [Y2Users::Config] config to validate
    attr_reader :config

    def duplicite_users
      grouped = config.users.all.group_by(&:uid)
      grouped.delete(nil)
      grouped.select! { |_uid, users| users.size > 1 } # colliding uids

      issues = grouped.map do |uid, users|
        msg = format(_("Users %{users} have same UID %{uid}."),
          users: users.map(&:name).join(", "),
          uid:   uid)
        Y2Issues::Issue.new(msg, location: USER_LOC, severity: :warn)
      end

      Y2Issues::List.new(issues)
    end

    def duplicite_groups
      grouped = config.groups.all.group_by(&:gid)
      grouped.delete(nil)
      grouped.select! { |_gid, groups| groups.size > 1 } # colliding uids

      issues = grouped.map do |gid, groups|
        msg = format(_("Groups %{groups} have same GID %{gid}."),
          groups: groups.map(&:name).join(", "),
          gid:    gid)
        Y2Issues::Issue.new(msg, location: GROUP_LOC, severity: :warn)
      end

      Y2Issues::List.new(issues)
    end
  end
end
