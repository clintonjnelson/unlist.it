require 'spec_helper'

describe Invitation do
  it {should belong_to(:sender).with_foreign_key(:user_id)}

end
