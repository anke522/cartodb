# encoding: utf-8

module Carto
  class OauthApp < ActiveRecord::Base
    belongs_to :user, inverse_of: :oauth_apps
    has_many :oauth_app_users, inverse_of: :oauth_app, dependent: :destroy

    validates :user, presence: true
    validates :name, presence: true
    validates :client_id, presence: true
    validates :client_secret, presence: true
    validates :redirect_urls, presence: true
    validate :validate_urls

    before_validation :generate_keys

    private

    def generate_keys
      self.client_id ||= SecureRandom.urlsafe_base64(9)
      self.client_secret ||= SecureRandom.urlsafe_base64(18)
    end

    def validate_urls
      redirect_urls.each { |url| validate_url(url) } if redirect_urls
    end

    def validate_url(url)
      uri = URI.parse(url)
      return errors.add(:redirect_urls, "#{url} must be absolute") unless uri.absolute?
      return errors.add(:redirect_urls, "#{url} must be https") unless uri.scheme == 'https'
      return errors.add(:redirect_urls, "#{url} must not contain a fragment") unless uri.fragment.nil?
    rescue URI::InvalidURIError
      errors.add(:redirect_urls, "#{url} must be valid")
    end
  end
end