require 'spec_helper'

describe Token do
  it { should validate_presence_of(  :tokenable ) }
  it { should validate_uniqueness_of(:creator   ).scoped_to(:tokenable) }
end
