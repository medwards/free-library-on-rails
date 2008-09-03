class CaseInsensitiveTags < ActiveRecord::Migration
  def self.up
		execute <<END
ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET latin1 UNIQUE COLLATE latin1_general_ci NOT NULL;
END
  end

	def self.down; end
end
