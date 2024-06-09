require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/around/spec'
require 'combine_pdf'

BASE_PATH = "test/fixtures/files/".freeze
describe 'CombinePDF.load' do
  let(:options) { {} }

  subject { CombinePDF.load BASE_PATH + file_path, options }

  describe 'raise_on_encrypted option' do
    let(:file_path) { 'sample_encrypted_pdf.pdf' }
    let(:options) { { raise_on_encrypted: raise_on_encrypted } }

    describe 'when raise_on_encrypted: true' do
      let(:raise_on_encrypted) { true }

      describe 'with encrypted file' do
        it('raises an CombinePDF::EncryptionError') do
          error = assert_raises(CombinePDF::EncryptionError) { subject }
          assert_match 'the file is encrypted', error.message
        end
      end

      describe 'with unencrypted file' do
        let(:file_path) { 'sample_pdf.pdf' }

        it('has a PDF') { assert_instance_of CombinePDF::PDF, subject }
      end
    end

    describe 'when raise_on_encrypted: false' do
      let(:raise_on_encrypted) { false }

      describe 'with encrypted file' do
        it('does not raise an CombinePDF::EncryptionError') do
          assert_instance_of CombinePDF::PDF, subject
        end
      end

      describe 'with unencrypted file' do
        let(:file_path) { 'sample_pdf.pdf' }

        it('has a PDF') { assert_instance_of CombinePDF::PDF, subject }
      end
    end
  end

  describe 'mute_malformed_error option' do
    let(:file_path) { 'malformed_scanned.pdf' }
    let(:options) { { mute_malformed_error: mute_malformed_error } }

    describe 'when mute_malformed_error: true' do
      let(:mute_malformed_error) { true }

      describe 'with malformed file' do
        it('does not raise an CombinePDF::ParsingError') do
          assert_instance_of CombinePDF::PDF, subject
        end
      end

      describe 'with unmalformed file' do
        let(:file_path) { 'sample_pdf.pdf' }

        it('has a PDF') { assert_instance_of CombinePDF::PDF, subject }
      end
    end

    describe 'when mute_malformed_error: false' do
      let(:mute_malformed_error) { false }

      describe 'with malformed file' do
        it('raises an CombinePDF::ParsingError') do
          error = assert_raises(CombinePDF::ParsingError) { subject }
          assert_match 'Unknown PDF parsing error - malformed PDF file?', error.message
        end
      end

      describe 'with unmalformed file' do
        let(:file_path) { 'sample_pdf.pdf' }

        it('has a PDF') { assert_instance_of CombinePDF::PDF, subject }
      end
    end
  end

  describe 'mute_range_error option' do
    let(:file_path) { 'out_range_scanned.pdf' }
    let(:options) { { mute_range_error: mute_range_error } }

    describe 'when mute_range_error: true' do
      let(:mute_range_error) { true }

      describe 'with out-range file' do
        it('does not raise an RangeError') do
          assert_instance_of CombinePDF::PDF, subject
        end
      end

      describe 'with in-range file' do
        let(:file_path) { 'sample_pdf.pdf' }

        it('has a PDF') { assert_instance_of CombinePDF::PDF, subject }
      end
    end

    describe 'when mute_range_error: false' do
      let(:mute_range_error) { false }

      describe 'with out-range file' do
        it('raises an RangeError') do
          error = assert_raises(RangeError) { subject }
          assert_match 'index out of range', error.message
        end
      end

      describe 'with in range file' do
        let(:file_path) { 'sample_pdf.pdf' }

        it('has a PDF') { assert_instance_of CombinePDF::PDF, subject }
      end
    end
  end
end
