require 'spec_helper'

describe Unpost do
  it { should belong_to(:user       ) }
  it { should belong_to(:category   ) }
  it { should belong_to(:condition  ) }

  it { should validate_presence_of(:title       ) }
  it { should validate_presence_of(:description ) }
  it { should validate_presence_of(:condition_id) }
  it { should validate_presence_of(:category_id ) }
  it { should validate_presence_of(:keyword1    ) }
  it { should validate_presence_of(:user_id     ) }
  it { should validate_presence_of(:travel      ) }
  it { should validate_numericality_of(:price   ).only_integer }
  it { should validate_numericality_of(:distance).only_integer }
  it { should validate_numericality_of(:zipcode ).only_integer }
  it { should allow_value("", nil).for(:keyword2) }
  it { should allow_value("", nil).for(:keyword3) }
  it { should allow_value("", nil).for(:keyword4) }
  it { should allow_value("", nil).for(:link    ) }
  it { should allow_value("", nil).for(:distance) }
end
