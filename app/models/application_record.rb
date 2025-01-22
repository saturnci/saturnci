class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.find_by_abbreviated_hash(abbreviated_hash)
    where("id::text LIKE ?", "#{abbreviated_hash}%").tap do |matching_records|
      if matching_records.count > 1
        raise StandardError, "Multiple records found matching #{abbreviated_hash}"
      end
    end.first
  end
end
