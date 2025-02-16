require "rails_helper"

RSpec.describe Blob, type: :model do
  let(:valid_attributes) {
    {
      uid: Faker::Internet.uuid,
      size: 256,
      storage_backend: "s3",
      storage_identifier: Faker::Internet.uuid
    }
  }

  it "is valid with valid attributes" do
    expect(Blob.new(valid_attributes)).to be_valid
  end

  it "is invalid without uid" do
    blob = Blob.new(valid_attributes.merge(uid: nil))
    expect(blob).not_to be_valid
  end

  it "requires unique uid" do
    Blob.create!(valid_attributes)
    duplicate = Blob.new(valid_attributes)
    expect(duplicate).not_to be_valid
  end
end
