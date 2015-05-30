#encoding: utf-8
require_relative 'spec_helper'

# deweller provided some nice unit tests for enconding/decoding transactions. 
# These examples were lifted from there.
describe Counterparty::TxDecode do
  # This converts the tokenly-unit test hash into what bitcoin-ruby expects:
  def tokenly_json_to_hash(json)
    hash = JSON.parse json
    
    { 'ver' => hash['version'], 'lock_time' => hash['locktime'],
      'in' => hash['vin'].collect{ |ain|
        { 'prev_out' => {'hash' => ain['txid'], 'n' => ain['n']},
          'scriptSig' => ain['scriptSig']['asm'], 'sequence' => ain['sequence']
        }
      },
      'out' => hash['vout'].collect{ |aout|
        {'value' => aout['value'], 'n' => aout['n'], 
         'scriptPubKey' => aout['scriptPubKey']['asm'] } } }
  end

  describe ".parse" do
    it "Tokenly's getSampleCounterpartyTransactionProtocol2()" do
      json  = '{"txid":"e0082d1fc37172ccf0f5ebfc3cc54291e463384712f44f32ba4996c02045966f","version":1,"locktime":0,"vin":[{"txid":"8fd9f689f158a426867215dbdee58e9eab6c818097d4bf2bcf0bd1458f3c55ab","vout":2,"scriptSig":{"asm":"3045022100a178c9accd7972cfe30a03c98ff5f684bdf0b144eb415f4a4b7fcff596283f720220267f68a6413093b97a42ed5c2f2811193c1bbdd07d668e3076f99751044c347a01 02f4aef682535628a7e0492b2b5db1aa312348c3095e0258e26b275b25b10290e6","hex":"483045022100a178c9accd7972cfe30a03c98ff5f684bdf0b144eb415f4a4b7fcff596283f720220267f68a6413093b97a42ed5c2f2811193c1bbdd07d668e3076f99751044c347a012102f4aef682535628a7e0492b2b5db1aa312348c3095e0258e26b275b25b10290e6"},"sequence":4294967295,"n":0,"addr":"1AuTJDwH6xNqxRLEjPB7m86dgmerYVQ5G1","valueSat":95270,"value":0.0009527,"doubleSpentTxID":null}],"vout":[{"value":"0.00005430","n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 1407ec32be440f32fc70f4eea810acd98f32aa32 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a9141407ec32be440f32fc70f4eea810acd98f32aa3288ac","reqSigs":1,"type":"pubkeyhash","addresses":["12pv1K6LTLPFYXcCwsaU7VWYRSX7BuiF28"]}},{"value":"0.00002500","n":1,"scriptPubKey":{"asm":"1 0276d539826e5ec10fed9ef597d5bfdac067d287fb7f06799c449971b9ddf9fec6 02af7efeb1f7cf0d5077ae7f7a59e2b643c5cd01fb55221bf76221d8c8ead92bf0 02f4aef682535628a7e0492b2b5db1aa312348c3095e0258e26b275b25b10290e6 3 OP_CHECKMULTISIG","hex":"51210276d539826e5ec10fed9ef597d5bfdac067d287fb7f06799c449971b9ddf9fec62102af7efeb1f7cf0d5077ae7f7a59e2b643c5cd01fb55221bf76221d8c8ead92bf02102f4aef682535628a7e0492b2b5db1aa312348c3095e0258e26b275b25b10290e653ae","reqSigs":1,"type":"multisig","addresses":["17MPn1QXt1SLqKWy3NPmJQ7iT5dJKRhCU7","12oEzNKh5TQpKDP1vfeTGnSjoxkboo1m5u","1AuTJDwH6xNqxRLEjPB7m86dgmerYVQ5G1"]}},{"value":"0.00086340","n":2,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 6ca4b6b20eac497e9ca94489c545a3372bdd2fa7 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a9146ca4b6b20eac497e9ca94489c545a3372bdd2fa788ac","reqSigs":1,"type":"pubkeyhash","addresses":["1AuTJDwH6xNqxRLEjPB7m86dgmerYVQ5G1"]}}],"valueOut":0.0009427,"size":340,"valueIn":0.0009527,"fees":0.00001}'

      tx = Bitcoin::P::Tx.from_hash( tokenly_json_to_hash(json) )
      record = Counterparty::TxDecode.new tx
      
      expect(record.data).to eq("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x17Hv\xE8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".force_encoding('ASCII-8BIT'))
      expect(record.destination).to eq('12pv1K6LTLPFYXcCwsaU7VWYRSX7BuiF28')

    end

    it "Tokenly's getSampleCounterpartyTransaction3()" do
        json = '{"txid":"24c9f9dd130591959b8f2e2e6d0133de028138bf73dfe14cc3de0fbb151812bd","version":1,"locktime":0,"vin":[{"txid":"e7f9319de85661c33130e80b7df16733164892eeb2e1fb044e5ac5de7a3269b7","vout":0,"scriptSig":{"asm":"304402205267657bb7ea5542b8fd32502e78dc3903e5781de8b8a5a119abbd382691a98e02204c47b7aa5940c030def956a4e91be16a692c09c7194a6fdec3054457c99e70c701 0257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690","hex":"47304402205267657bb7ea5542b8fd32502e78dc3903e5781de8b8a5a119abbd382691a98e02204c47b7aa5940c030def956a4e91be16a692c09c7194a6fdec3054457c99e70c701210257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690"},"sequence":4294967295,"n":0,"addr":"1291Z6hofAAvH8E886cN9M5uKB1VvwBnup","valueSat":5430,"value":0.0000543,"doubleSpentTxID":null},{"txid":"d800ef4c33542c90bcfe4cd0c2fc2c0d120877ec933ca869177a77eb8b42077e","vout":1,"scriptSig":{"asm":"3045022100e43310957b541c51e00c3076393bf93c23dd72306a012f0ebe1024218269045d022029b5218047adf59186d53dbff7a249f82003e923a782cdfd75f8871b89c819b801 0257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690","hex":"483045022100e43310957b541c51e00c3076393bf93c23dd72306a012f0ebe1024218269045d022029b5218047adf59186d53dbff7a249f82003e923a782cdfd75f8871b89c819b801210257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690"},"sequence":4294967295,"n":1,"addr":"1291Z6hofAAvH8E886cN9M5uKB1VvwBnup","valueSat":801320,"value":0.0080132,"doubleSpentTxID":null}],"vout":[{"value":"0.00005430","n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 9c2401388e6d2752a496261e9130cd54ddb2b262 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a9149c2401388e6d2752a496261e9130cd54ddb2b26288ac","reqSigs":1,"type":"pubkeyhash","addresses":["1FEbYaghvr7V53B9csjQTefUtBBQTaDFvN"]}},{"value":"0.00002500","n":1,"scriptPubKey":{"asm":"1 035240874259b8f93dffc6ffa29b09d0d06dfb072d9646ae777480a2c521bfdbb1 0264f1dd503423e8305e19fc77b4e26dc8ec8a8f500b1bec580112af8c64e74b1b 0257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c690 3 OP_CHECKMULTISIG","hex":"5121035240874259b8f93dffc6ffa29b09d0d06dfb072d9646ae777480a2c521bfdbb1210264f1dd503423e8305e19fc77b4e26dc8ec8a8f500b1bec580112af8c64e74b1b210257b0d96d1fe64fbb95b2087e68592ee016c50f102d8dcf776ed166473f27c69053ae","reqSigs":1,"type":"multisig","addresses":["1J7TTrHcWQgs37Es8PFKcaoJmUvGRGsEzY","126HYzAnxybKoHpkmrMBSSu3KnqzUgEHGc","1291Z6hofAAvH8E886cN9M5uKB1VvwBnup"]}},{"value":"0.00793820","n":2,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 0c7bea5ae61ccbc157156ffc9466a54b07bfe951 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a9140c7bea5ae61ccbc157156ffc9466a54b07bfe95188ac","reqSigs":1,"type":"pubkeyhash","addresses":["1291Z6hofAAvH8E886cN9M5uKB1VvwBnup"]}}],"valueOut":0.0080175,"size":487,"valueIn":0.0080675,"fees":0.00005}'

      tx = Bitcoin::P::Tx.from_hash( tokenly_json_to_hash(json) )
      record = Counterparty::TxDecode.new tx
      
      expect(record.data).to eq("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x00\v\xEB\xC2\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".force_encoding('ASCII-8BIT'))
      expect(record.destination).to eq('1FEbYaghvr7V53B9csjQTefUtBBQTaDFvN')
    end


    it "Tokenly's getSampleCounterpartyTransaction4()" do
      json = '{"txid":"2d1fea72ea4be25793d8a2e254c6dc4aacfac8978ce0cc4729fe1418649c8f1e","version":1,"locktime":0,"vin":[{"txid":"a6edb86171fc7736389f20bc63542255dbbfa2dcd173fc079414adab7f548071","vout":0,"scriptSig":{"asm":"3044022038397429f0a49e80690eb143e63d83c097288b2c1ea90167688997e8a75a3c8402204e48260b4440001d402b40a33183dc5d54d5ced64670b0e5b72373392c8481d501 034bf23d14fa8aa9e8ebfee6e0bf986fa36ad61434068b89b7a8801506ed5060bb","hex":"473044022038397429f0a49e80690eb143e63d83c097288b2c1ea90167688997e8a75a3c8402204e48260b4440001d402b40a33183dc5d54d5ced64670b0e5b72373392c8481d50121034bf23d14fa8aa9e8ebfee6e0bf986fa36ad61434068b89b7a8801506ed5060bb"},"sequence":4294967295,"n":0,"addr":"1MFHQCPGtcSfNPXAS6NryWja3TbUN9239Y","valueSat":5430,"value":0.0000543,"doubleSpentTxID":null},{"txid":"31aa31fb22cd24d54b68ef7390ed39db09f2e4cbae1c227b2f78087f3edf4077","vout":1,"scriptSig":{"asm":"30440220189f79d7c86884d69f35cb7d8b96916bc3001c522a2025471675a6835fc45b7d02203345a31b0abb79035722a9ed5381fd34380f4e9cc418a5ea522034e50ea1f2e901 034bf23d14fa8aa9e8ebfee6e0bf986fa36ad61434068b89b7a8801506ed5060bb","hex":"4730440220189f79d7c86884d69f35cb7d8b96916bc3001c522a2025471675a6835fc45b7d02203345a31b0abb79035722a9ed5381fd34380f4e9cc418a5ea522034e50ea1f2e90121034bf23d14fa8aa9e8ebfee6e0bf986fa36ad61434068b89b7a8801506ed5060bb"},"sequence":4294967295,"n":1,"addr":"1MFHQCPGtcSfNPXAS6NryWja3TbUN9239Y","valueSat":1717640,"value":0.0171764,"doubleSpentTxID":null}],"vout":[{"value":"0.00005430","n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 fd84ff1f2cc1b0299165e2804fccd6fb0bd48d0b OP_EQUALVERIFY OP_CHECKSIG","hex":"76a914fd84ff1f2cc1b0299165e2804fccd6fb0bd48d0b88ac","reqSigs":1,"type":"pubkeyhash","addresses":["1Q7VHJDEzVj7YZBVseQWgYvVj3DWDCLwDE"]}},{"value":"0.00000000","n":1,"scriptPubKey":{"asm":"OP_RETURN 2c54fff6d3e165e008f5ec45a06951e6b6fb4a162fcfec34aa1f0dd8","hex":"6a1c2c54fff6d3e165e008f5ec45a06951e6b6fb4a162fcfec34aa1f0dd8","type":"nulldata"}},{"value":"0.01712640","n":2,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 de1607744008a3edeabae06365a9aa2b131d5dc2 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a914de1607744008a3edeabae06365a9aa2b131d5dc288ac","reqSigs":1,"type":"pubkeyhash","addresses":["1MFHQCPGtcSfNPXAS6NryWja3TbUN9239Y"]}}],"blockhash":"00000000000000000d7fbe3a59b9d37380fb46a79289e2011396721c433a7883","confirmations":1,"time":1428589045,"blocktime":1428589045,"valueOut":0.0171807,"size":411,"valueIn":0.0172307,"fees":0.00005}'

      tx = Bitcoin::P::Tx.from_hash( tokenly_json_to_hash(json) )
      record = Counterparty::TxDecode.new tx
      
      expect(record.data).to eq("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x00\x05\xF5\xE1\x00".force_encoding('ASCII-8BIT'))
    end

    it "Tokenly's getSampleCounterpartyTransaction5()" do
      json = '{"txid":"48e07bdad04f869850ccdb11b5e6a9e89ee8023111eb4f2e293d3e8ef75befee","version":1,"locktime":0,"vin":[{"txid":"cf8fa29cf63938a787e732c85071695668b9e00bfedff807dfbdc85a6ad6a696","vout":0,"scriptSig":{"asm":"304502210089af043911012c558bd11392d4346da725cd35822c1c6c0140293fed3344176d02207e6ad3945cb6580e654ac579a3ffdc01b93e54c4babc55bde6aa2b97ddf3f0af01 02b0610c458d67d76e348c6bb2f29f66d272e2c66bd23747ac401fefa45d2fc7a0","hex":"48304502210089af043911012c558bd11392d4346da725cd35822c1c6c0140293fed3344176d02207e6ad3945cb6580e654ac579a3ffdc01b93e54c4babc55bde6aa2b97ddf3f0af012102b0610c458d67d76e348c6bb2f29f66d272e2c66bd23747ac401fefa45d2fc7a0"},"sequence":4294967295,"n":0,"addr":"12iVwKP7jCPnuYy7jbAbyXnZ3FxvgLwvGK","valueSat":5430,"value":0.0000543,"doubleSpentTxID":null},{"txid":"d6e1e95bae2a4715dce049f464525af1f118876b7e79c311e1fa4c2bf77f4df4","vout":2,"scriptSig":{"asm":"30440220459ef45b40a80a9dc1cb2c33d1f5ddd8d464c4a607dbe2df83049d69b35c7b960220134b69e807eb2bebc3339bfb60a7de5b86c801f64d176fc704a3ce9132e8509301 02b0610c458d67d76e348c6bb2f29f66d272e2c66bd23747ac401fefa45d2fc7a0","hex":"4730440220459ef45b40a80a9dc1cb2c33d1f5ddd8d464c4a607dbe2df83049d69b35c7b960220134b69e807eb2bebc3339bfb60a7de5b86c801f64d176fc704a3ce9132e85093012102b0610c458d67d76e348c6bb2f29f66d272e2c66bd23747ac401fefa45d2fc7a0"},"sequence":4294967295,"n":1,"addr":"12iVwKP7jCPnuYy7jbAbyXnZ3FxvgLwvGK","valueSat":1760000,"value":0.0176,"doubleSpentTxID":null}],"vout":[{"value":"0.00005430","n":0,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 cab7d87116e620e10a69e666ec6494d4607631e7 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a914cab7d87116e620e10a69e666ec6494d4607631e788ac","reqSigs":1,"type":"pubkeyhash","addresses":["1KUsjZKrkd7LYRV7pbnNJtofsq1HAiz6MF"]}},{"value":"0.00000000","n":1,"scriptPubKey":{"asm":"OP_RETURN fb706d6b2839cfd52a4b50cb135f18cf9e0b280ca45b2da5694229f0","hex":"6a1cfb706d6b2839cfd52a4b50cb135f18cf9e0b280ca45b2da5694229f0","type":"nulldata"}},{"value":"0.01755000","n":2,"scriptPubKey":{"asm":"OP_DUP OP_HASH160 12d155cefea286e9d3cda6cb64cd8d26a5b95780 OP_EQUALVERIFY OP_CHECKSIG","hex":"76a91412d155cefea286e9d3cda6cb64cd8d26a5b9578088ac","reqSigs":1,"type":"pubkeyhash","addresses":["12iVwKP7jCPnuYy7jbAbyXnZ3FxvgLwvGK"]}}],"valueOut":0.0176043,"size":412,"valueIn":0.0176543,"fees":0.00005}'

      tx = Bitcoin::P::Tx.from_hash( tokenly_json_to_hash(json) )
      record = Counterparty::TxDecode.new tx
      
      expect(record.data).to eq("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xFA\xDF\x00\x00\x00\x01*\x05\xF2\x00".force_encoding('ASCII-8BIT'))
      expect(record.destination).to eq('1KUsjZKrkd7LYRV7pbnNJtofsq1HAiz6MF')
    end

    it "decodes a random counterparty transaction" do
      # This was from a random Counterparty Broadcast. Txid:
      #   eae1fd843f267d756c765b3e84ff33cd3f7dcde4df671c53b2e3465ba9f1b94e

      #raw_tx = BlockrIo.new.getrawtransaction random_cp_broadcast
      random_cp_broadcast_raw_tx = '0100000001c77af36618fa11f91152608a6ed50'+
        'eab0fed0c9ace1a1f60444e8abb15d5cdd6010000006b4830450220243fa1706a7'+
        '708ffa5313a04935fd543f5fd04d43f3f8d6c46e94502dfabcb08022100a682848'+
        'c79356ab47e17b3f10ed91e45c72ad0fc866c2e4a4bb25826ef9ac00f01210216b'+
        '6c3047c80b4e2fcbed0df1b265d73dbef174291fcb4cdc427cef12ea3cf3cfffff'+
        'fff03781e00000000000069512103d468e197eaad3c41aac3aca739bb6a6a9a96f'+
        '7c8446ae8055d3889b7a3d5219f21021875e020f9fac3f2654d173b110b0354db4'+
        'ff931b5aa069bb090a15521164a73210216b6c3047c80b4e2fcbed0df1b265d73d'+
        'bef174291fcb4cdc427cef12ea3cf3c53ae781e00000000000069512103f968e19'+
        '7eaad3c41aaa0cfc5559c59a8412907c8446ae8055d3889b7a3fd63092102543aa'+
        '36baab982bc451b5269584d5a799a0bbd63f0f955bb84fdcc244020238a210216b'+
        '6c3047c80b4e2fcbed0df1b265d73dbef174291fcb4cdc427cef12ea3cf3c53ae3'+
        '3009718000000001976a914b14a2f25ceaa17b72a089813eae8f33f9dddeb0c88a'+
        'c00000000'
    

      tx = Bitcoin::P::Tx.new [random_cp_broadcast_raw_tx].pack('H*')
      record = Counterparty::TxDecode.new tx
      
      expect(record.data).to eq("\x00\x00\x00\x1EUT\xA9\xA2\xBF\xF0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00(BLOCKSCAN VERIFY-ADDRESS 4mmqa6iccbrrgky\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".force_encoding('ASCII-8BIT'))
      expect(record.destination).to eq(nil)
    end

  end
end

