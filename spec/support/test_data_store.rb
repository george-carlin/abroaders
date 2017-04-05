# When a spec file requires a lot of records to be created, you can speed up
# the suite dramatically by moving the creation of those records into a
# before(:all) block. The problem then is that you need to make sure these
# records get cleaned up (i.e. deleted) at the end of the test run.
#
# In non-JS tests this is already taken care of, because everything created
# in before(:each) is wrapped within a transaction and so never truly gets
# saved, and everything created in before(:all) gets cleaned up in after(:all)
# by DatabaseCleaner (see rails_helper). But this doesn't work in JS tests
# because they're not wrapped in a transaction. So pass :manual_clean
# to the specs as metadata and the below hackery will take care of things:

class TestDataStore
  def self.records
    @records ||= []
  end

  def self.clean
    # Destroy records in the reverse order to which they were created. In the
    # original direction, you may find some records can't be deleted because
    # later records have foreign keys which point to them.
    TestDataStore.records.reject(&:destroyed?).reverse.each(&:destroy)
  end
end

ApplicationRecord.class_eval do
  cattr_accessor :__storing_on
  after_create :__store_test_data, if: :__storing_on

  def __store_test_data
    TestDataStore.records << self
  end
end
