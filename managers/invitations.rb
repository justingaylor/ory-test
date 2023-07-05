require 'sqlite3'
require 'singleton'
require 'securerandom'

module Managers
  class Invitations
    include Singleton

    def initialize
      @db = SQLite3::Database.new(':memory:')
    end

    def setup
      # Create our invitations table
      # In a real implementation, we'd use migrations
      # to set this up.
      @db.execute <<~SQL
        CREATE TABLE invitations(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          status TEXT
        );
      SQL
    end

    def create_invitation_for_user(user_id)
      invitation_id = SecureRandom.uuid
      @db.execute(
        "INSERT INTO invitations (id, user_id, status) VALUES (?, ?, ?)", 
        [invitation_id, user_id, 'pending']
      )
      invitation_id
    end

    def complete_invitation(invitation_id)
      @db.execute(
        "UPDATE invitations SET status = 'completed' WHERE id = ?", 
        [invitation_id]
      )
    end

    def get_invitations
      result_set = @db.execute("SELECT * FROM invitations")
      
      # convert the raw result set to a more friendly format
      result_set.map do |row|
        { id: row[0], user_id: row[1], status: row[2] }
      end
    end

    def get_invitation(invitation_id)
      result = @db.get_first_row(
        "SELECT * FROM invitations WHERE id = ?", 
        [invitation_id]
      )

      { id: result[0], user_id: result[1], status: result[2] }
    end
  end
end