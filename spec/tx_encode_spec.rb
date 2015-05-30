#encoding: utf-8
require_relative 'spec_helper'

describe Counterparty::TxEncode do
  describe ".encode" do
    it "Tokenly's getSampleCounterpartyTransactionProtocol2()" do
      encoder = Counterparty::TxEncode.new "12pv1K6LTLPFYXcCwsaU7VWYRSX7BuiF28",
        # Key:
        "\x8F\xD9\xF6\x89\xF1X\xA4&\x86r\x15\xDB\xDE\xE5\x8E\x9E\xABl\x81"+
        "\x80\x97\xD4\xBF+\xCF\v\xD1E\x8F<U\xAB",
        # Data:
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x17Hv"+
        "\xE8\x00\x00\x00\x00\x00\x00\x00\x00\x00",
        :sender_pubkey => '02f4aef682535628a7e0492b2b5db1aa312348c3095e0258e26b275b25b10290e6'

      expect(encoder.to_opmultisig).to eq([
        "OP_DUP OP_HASH160 1407ec32be440f32fc70f4eea810acd98f32aa32 OP_EQUALVERIFY OP_CHECKSIG",
        "1 0276d539826e5ec10fed9ef597d5bfdac067d287fb7f06799c449971b9ddf9fec6 02af7efeb1f7cf0d5077ae7f7a59e2b643c5cd01fb55221bf76221d8c8ead92bf0 02f4aef682535628a7e0492b2b5db1aa312348c3095e0258e26b275b25b10290e6 3 OP_CHECKMULTISIG",
        "OP_DUP OP_HASH160 6ca4b6b20eac497e9ca94489c545a3372bdd2fa7 OP_EQUALVERIFY OP_CHECKSIG"
        ].join("\n") )
    end

    it "Tokenly's getSampleCounterpartyTransaction3()" do
      encoder = Counterparty::TxEncode.new "1FEbYaghvr7V53B9csjQTefUtBBQTaDFvN",
        # Key:
        "\xE7\xF91\x9D\xE8Va\xC310\xE8\v}\xF1g3\x16H\x92\xEE\xB2\xE1\xFB"+
        "\x04NZ\xC5\xDEz2i\xB7",
        # Data:
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x00\v"+
        "\xEB\xC2\x00\x00\x00\x00\x00\x00\x00\x00\x00",
        :sender_pubkey => "0257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690"

      expect(encoder.to_opmultisig).to eq([
        "OP_DUP OP_HASH160 9c2401388e6d2752a496261e9130cd54ddb2b262 OP_EQUALVERIFY OP_CHECKSIG",
        "1 035240874259b8f93dffc6ffa29b09d0d06dfb072d9646ae777480a2c521bfdbb1 0264f1dd503423e8305e19fc77b4e26dc8ec8a8f500b1bec580112af8c64e74b1b 0257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690 3 OP_CHECKMULTISIG",
        "OP_DUP OP_HASH160 0c7bea5ae61ccbc157156ffc9466a54b07bfe951 OP_EQUALVERIFY OP_CHECKSIG"
        ].join("\n") )
    end

    it "Tokenly's getSampleCounterpartyTransaction4()" do
      encoder = Counterparty::TxEncode.new "1Q7VHJDEzVj7YZBVseQWgYvVj3DWDCLwDE",
        # Key:
        "\xA6\xED\xB8aq\xFCw68\x9F \xBCcT\"U\xDB\xBF\xA2\xDC\xD1s\xFC\a\x94"+
        "\x14\xAD\xAB\x7FT\x80q",
        # Data:
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x00"+
        "\x05\xF5\xE1\x00", 
        :sender_addr => '1MFHQCPGtcSfNPXAS6NryWja3TbUN9239Y'

      expect(encoder.to_opreturn).to eq([
        "OP_DUP OP_HASH160 fd84ff1f2cc1b0299165e2804fccd6fb0bd48d0b OP_EQUALVERIFY OP_CHECKSIG",
        "OP_RETURN 2c54fff6d3e165e008f5ec45a06951e6b6fb4a162fcfec34aa1f0dd8",
        "OP_DUP OP_HASH160 de1607744008a3edeabae06365a9aa2b131d5dc2 OP_EQUALVERIFY OP_CHECKSIG"
      ].join("\n") )
    end

    it "Tokenly's getSampleCounterpartyTransaction5()" do
      encoder = Counterparty::TxEncode.new "1KUsjZKrkd7LYRV7pbnNJtofsq1HAiz6MF",
        # Key:
        "\xCF\x8F\xA2\x9C\xF698\xA7\x87\xE72\xC8PqiVh\xB9\xE0\v\xFE\xDF\xF8"+
        "\a\xDF\xBD\xC8Zj\xD6\xA6\x96",
        # Data:
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x01*"+
        "\x05\xF2\x00",
        :sender_addr => '12iVwKP7jCPnuYy7jbAbyXnZ3FxvgLwvGK'

      expect(encoder.to_opreturn).to eq([
        "OP_DUP OP_HASH160 cab7d87116e620e10a69e666ec6494d4607631e7 OP_EQUALVERIFY OP_CHECKSIG",
        "OP_RETURN fb706d6b2839cfd52a4b50cb135f18cf9e0b280ca45b2da5694229f0",
        "OP_DUP OP_HASH160 12d155cefea286e9d3cda6cb64cd8d26a5b95780 OP_EQUALVERIFY OP_CHECKSIG"
      ].join("\n") )
    end

  end
end
