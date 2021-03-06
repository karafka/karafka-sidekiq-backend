# frozen_string_literal: true

module Karafka
  # Interchanger allows us to format/encode/pack data that is being send to perform_async
  # This is meant to target mostly issues with data encoding like this one:
  # https://github.com/mperham/sidekiq/issues/197
  # Each custom interchanger should implement following methods:
  #   - encode - it is meant to encode params before they get stored inside Redis
  #   - decode - decoded params back to a hash format that we can use
  #
  # This interchanger uses default Sidekiq options to exchange data
  class Interchanger
    # @param params_batch [Karafka::Params::ParamsBatch] Karafka params batch object
    # @return [Array<Hash>] Array with hash built out of params data
    def encode(params_batch)
      params_batch.map do |param|
        {
          'raw_payload' => param.raw_payload,
          'metadata' => param.metadata.to_h
        }
      end
    end

    # @param params_batch [Array<Hash>] Sidekiq params that are now an array
    # @return [Array<Hash>] exactly what we've fetched from Sidekiq
    def decode(params_batch)
      params_batch
    end
  end
end
