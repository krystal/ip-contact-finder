# frozen_string_literal: true

require 'spec_helper'
require 'ip_contact_finder/rdap'

module IPContactFinder
  RSpec.describe RDAP do
    subject(:rdap) { described_class.new }

    describe '#ip' do
      it 'forwards the request to the lookup method' do
        expect(rdap).to receive(:lookup).with('ip', '8.8.8.8')
        rdap.ip('8.8.8.8')
      end
    end

    describe '#autnum' do
      it 'forwards the request to the lookup method' do
        expect(rdap).to receive(:lookup).with('autnum', '60899')
        rdap.autnum('60899')
      end
    end

    describe '#entity' do
      it 'forwards the request to the lookup method' do
        expect(rdap).to receive(:lookup).with('entity', 'AC23456-RIPE')
        rdap.entity('AC23456-RIPE')
      end
    end

    describe '#lookup' do
      it 'returns details for a given IP address' do
        VCR.use_cassette('valid_ip') do
          result = rdap.lookup('ip', '185.22.208.0')
          expect(result).to be_a Hash
          expect(result['startAddress']).to eq '185.22.208.0'
        end
      end

      it 'will follow a redirect to another RIR if needed' do
        VCR.use_cassette('valid_ip_with_redirect') do
          result = rdap.lookup('ip', '8.8.8.8')
          expect(result).to be_a Hash
          expect(result['startAddress']).to eq '8.8.8.0'
          expect(result['port43']).to eq 'whois.arin.net'
        end
      end

      it 'will raise an error if the given IP is not found' do
        VCR.use_cassette('ip_not_found') do
          expect { rdap.lookup('ip', '245.2.2.1') }.to raise_error IPContactFinder::NotFoundError
        end
      end

      it 'will raise an error if a rate limit is reached' do
        VCR.use_cassette('ip_rate_limited') do
          expect { rdap.lookup('ip', '185.22.208.0') }.to raise_error IPContactFinder::RateLimitedError
        end
      end

      it 'will raise an error if you get a bad request' do
        VCR.use_cassette('ip_invalid') do
          expect { rdap.lookup('ip', '185.22.208.444') }.to raise_error IPContactFinder::RequestError
        end
      end

      it 'will raise an error if there is a timeout' do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)
        expect { rdap.lookup('ip', '185.22.208.0') }.to raise_error IPContactFinder::RequestError do |e|
          expect(e.message).to eq 'Timeout::Error (Timeout::Error)'
        end
      end

      it 'will raise an error if there is a connection issue' do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError)
        expect { rdap.lookup('ip', '185.22.208.0') }.to raise_error IPContactFinder::RequestError do |e|
          expect(e.message).to eq 'SocketError (SocketError)'
        end
      end
    end
  end
end
