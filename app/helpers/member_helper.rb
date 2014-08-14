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

  enumerize :province, :in => {
    'Amnat Charoen' => 1,
    'Ang Thong' => 2,
    'Bangkok' => 3,
    'Beung Kan' => 4
  }, scope: true

  enumerize :salary, :in => {
    'No Income' => 0,
    'Lower than 18,000 THB' => 1,
    '18,001 - 30,000' => 2,
    '30,001 - 50,000' => 3,
    '50,001 - 100,000' => 4,
    'More than 100,001' => 5
  }, scope: true

end




    # Province.create!(:name => 'Bangkok')
    # Province.create!(:name => 'Amnat Charoen')
    # Province.create!(:name => 'Ang Thong')
    # Province.create!(:name => 'Beung Kan')
    # Province.create!(:name => 'Buriram')
    # Province.create!(:name => 'Chachoengsao')
    # Province.create!(:name => 'Chai Nat')
    # Province.create!(:name => 'Chaiyaphum')
    # Province.create!(:name => 'Chanthaburi')
    # Province.create!(:name => 'Chiang Mai')
    # Province.create!(:name => 'Chiang Rai')
    # Province.create!(:name => 'Chon Buri')
    # Province.create!(:name => 'Chumphon')
    # Province.create!(:name => 'Kalasin')
    # Province.create!(:name => 'Kamphaeng Phet')
    # Province.create!(:name => 'Kanchanaburi')
    # Province.create!(:name => 'Khon Kaen')
    # Province.create!(:name => 'Krabi')
    # Province.create!(:name => 'Lampang')
    # Province.create!(:name => 'Lamphun')
    # Province.create!(:name => 'Loei')
    # Province.create!(:name => 'Lop Buri')
    # Province.create!(:name => 'Mae Hong Son')
    # Province.create!(:name => 'Maha Sarakham')
    # Province.create!(:name => 'Mukdahan')
    # Province.create!(:name => 'Nakhon Nayok')
    # Province.create!(:name => 'Nakhon Pathom')
    # Province.create!(:name => 'Nakhon Phanom')
    # Province.create!(:name => 'Nakhon Ratchasima')
    # Province.create!(:name => 'Nakhon Sawan')
    # Province.create!(:name => 'Nakhon Si Thammarat')
    # Province.create!(:name => 'Nan')
    # Province.create!(:name => 'Narathiwat')
    # Province.create!(:name => 'Nong Bua Lamphu')
    # Province.create!(:name => 'Nong Khai')
    # Province.create!(:name => 'Nonthaburi')
    # Province.create!(:name => 'Pathum Thani')
    # Province.create!(:name => 'Pattani')
    # Province.create!(:name => 'Phangnga')
    # Province.create!(:name => 'Phatthalung')
    # Province.create!(:name => 'Phayao')
    # Province.create!(:name => 'Phetchabun')
    # Province.create!(:name => 'Phetchaburi')
    # Province.create!(:name => 'Phichit')
    # Province.create!(:name => 'Phitsanulok')
    # Province.create!(:name => 'Phra Nakhon Si Ayutthaya')
    # Province.create!(:name => 'Phrae')
    # Province.create!(:name => 'Phuket')
    # Province.create!(:name => 'Prachin Buri')
    # Province.create!(:name => 'Prachuap Khiri Khan')
    # Province.create!(:name => 'Ranong')
    # Province.create!(:name => 'Ratchaburi')
    # Province.create!(:name => 'Rayong')
    # Province.create!(:name => 'Roi Et')
    # Province.create!(:name => 'Sa Kaeo')
    # Province.create!(:name => 'Sakon Nakhon')
    # Province.create!(:name => 'Samut Prakan')
    # Province.create!(:name => 'Samut Sakhon')
    # Province.create!(:name => 'Samut Songkhram')
    # Province.create!(:name => 'Sara Buri')
    # Province.create!(:name => 'Satun')
    # Province.create!(:name => 'Sing Buri')
    # Province.create!(:name => 'Sisaket')
    # Province.create!(:name => 'Songkhla')
    # Province.create!(:name => 'Sukhothai')
    # Province.create!(:name => 'Suphan Buri')
    # Province.create!(:name => 'Surat Thani')
    # Province.create!(:name => 'Surin')
    # Province.create!(:name => 'Tak')
    # Province.create!(:name => 'Trang')
    # Province.create!(:name => 'Trat')
    # Province.create!(:name => 'Ubon Ratchathani')
    # Province.create!(:name => 'Udon Thani')
    # Province.create!(:name => 'Uthai Thani')
    # Province.create!(:name => 'Uttaradit')
    # Province.create!(:name => 'Yala')
    # Province.create!(:name => 'Yasothon')