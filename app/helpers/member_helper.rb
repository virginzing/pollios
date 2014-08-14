module MemberHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :gender, :in => { :male => 1, :female => 2, :custom => 3 }, scope: :true, predicates: true
  enumerize :interests, :in => {
    :anime => 1,
    :manga => 2,
    :goods => 3
  }, scope: :true, predicates: true, multiple: true

  enumerize :member_type, :in => { citizen: 0, celebrity: 1, brand: 2, company: 3 }, predicates: true, default: :citizen, scope: true
  enumerize :status_account, :in => { normal: 1, blacklist: -1 }, default: :normal, predicates: true, scope: :having_status_account

  enumerize :salary, :in => {
    'No Income' => 0,
    'Lower than 18,000 THB' => 1,
    '18,001 - 30,000' => 2,
    '30,001 - 50,000' => 3,
    '50,001 - 100,000' => 4,
    'More than 100,001' => 5
  }, scope: true

  enumerize :province, :in => {"Bangkok"=>1, "Amnat Charoen"=>2, "Ang Thong"=>3, "Beung Kan"=>4, "Buriram"=>5, "Chachoengsao"=>6, "Chai Nat"=>7, "Chaiyaphum"=>8, "Chanthaburi"=>9, "Chiang Mai"=>10, "Chiang Rai"=>11, "Chon Buri"=>12, "Chumphon"=>13, "Kalasin"=>14, "Kamphaeng Phet"=>15, "Kanchanaburi"=>16, "Khon Kaen"=>17, "Krabi"=>18, "Lampang"=>19, "Lamphun"=>20, "Loei"=>21, "Lop Buri"=>22, "Mae Hong Son"=>23, "Maha Sarakham"=>24, "Mukdahan"=>25, "Nakhon Nayok"=>26, "Nakhon Pathom"=>27, "Nakhon Phanom"=>28, "Nakhon Ratchasima"=>29, "Nakhon Sawan"=>30, "Nakhon Si Thammarat"=>31, "Nan"=>32, "Narathiwat"=>33, "Nong Bua Lamphu"=>34, "Nong Khai"=>35, "Nonthaburi"=>36, "Pathum Thani"=>37, "Pattani"=>38, "Phangnga"=>39, "Phatthalung"=>40, "Phayao"=>41, "Phetchabun"=>42, "Phetchaburi"=>43, "Phichit"=>44, "Phitsanulok"=>45, "Phra Nakhon Si Ayutthaya"=>46, "Phrae"=>47, "Phuket"=>48, "Prachin Buri"=>49, "Prachuap Khiri Khan"=>50, "Ranong"=>51, "Ratchaburi"=>52, "Rayong"=>53, "Roi Et"=>54, "Sa Kaeo"=>55, "Sakon Nakhon"=>56, "Samut Prakan"=>57, "Samut Sakhon"=>58, "Samut Songkhram"=>59, "Sara Buri"=>60, "Satun"=>61, "Sing Buri"=>62, "Sisaket"=>63, "Songkhla"=>64, "Sukhothai"=>65, "Suphan Buri"=>66, "Surat Thani"=>67, "Surin"=>68, "Tak"=>69, "Trang"=>70, "Trat"=>71, "Ubon Ratchathani"=>72, "Udon Thani"=>73, "Uthai Thani"=>74, "Uttaradit"=>75, "Yala"=>76, "Yasothon"=>77}, scope: true

end