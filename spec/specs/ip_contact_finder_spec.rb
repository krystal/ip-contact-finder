# frozen_string_literal: true

require 'spec_helper'
require 'ip_contact_finder'

RSpec.describe IPContactFinder do
  describe '#lookup' do
    it 'forwards requests for IPv4 addresses to the #ip method' do
      expect(described_class).to receive(:ip).with('1.2.3.4')
      described_class.lookup('1.2.3.4')
    end

    it 'forwards requests for IPv6 addresses to the #ip method' do
      expect(described_class).to receive(:ip).with('2a00:67a0:a::1')
      described_class.lookup('2a00:67a0:a::1')
    end

    it 'forwards requests for aut nums to the #autnum method' do
      expect(described_class).to receive(:autnum).with('60899')
      described_class.lookup('60899')
    end

    it 'forwards requests for entities to the #entity method' do
      expect(described_class).to receive(:entity).with('AC23456-RIPE')
      described_class.lookup('AC23456-RIPE')
    end
  end

  describe '#ip' do
    it 'raises an error if the ip is invalid' do
      expect { described_class.ip('invalid') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.ip('2.3.4') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.ip('500.2.3.4') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.ip(' asd akjhasdkjh ') }.to raise_error IPContactFinder::InvalidObjectError
    end

    it 'returns an array of IP addresses' do
      VCR.use_cassette('valid_krystal_ip') do
        expect(described_class.ip('185.22.208.0')).to eq ['abuse@krystal.uk', 'noc@krystal.co.uk']
      end
    end
  end

  describe '#autnum' do
    it 'raises an error if the aut num is invalid' do
      expect { described_class.autnum('invalid') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.autnum('2.3.4') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.autnum('500.2.3.4') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.autnum('asd akjhasdkjh ') }.to raise_error IPContactFinder::InvalidObjectError
    end

    it 'returns an array of IP addresses' do
      VCR.use_cassette('valid_krystal_autnum') do
        expect(described_class.autnum('60899')).to eq ['noc@krystal.co.uk']
      end
    end
  end

  describe '#entity' do
    it 'raises an error if the entity is invalid' do
      expect { described_class.autnum('**&&&') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.autnum('2.3.4') }.to raise_error IPContactFinder::InvalidObjectError
      expect { described_class.autnum('500.2.3.4') }.to raise_error IPContactFinder::InvalidObjectError
    end

    it 'returns an array of IP addresses' do
      VCR.use_cassette('valid_krystal_entity') do
        expect(described_class.entity('KNOC3-RIPE')).to eq ['noc@krystal.co.uk']
      end
    end
  end
end
