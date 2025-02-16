class Blob < ApplicationRecord
    validates :uid, presence: true, uniqueness: true
    validates :size, presence: true
    validates :storage_backend, presence: true
    validates :storage_identifier, presence: true
end
