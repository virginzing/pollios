# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# i = 50
# 50.times do
#   Member.create!(sentai_id: i, sentai_name: Faker::Name.name, username: Faker::Name.first_name, email: Faker::Internet.email, friend_limit: 500)
#   i += 1
# end


# after rollback must create pollios account first

# after rollback must create system setting



# PollMember.select("poll_id").where("member_id = ? OR member_id IN (?)", 1, [2, 3]).group.order("poll_id asc")

# @series = PollSeries.create!(member_id: 8, description: "แบบสำรวจความพึงพอใจการให้บริการในการจัดโครงการสัมมนาผู้รับผิดชอบด้านพลังงาน", vote_all: 0, view_all: 0, expire_date: Time.now + 2.days)

# @polls = @series.polls.create!(title: "คุณชอบตัวละครตัวไหนมากที่สุด")
# @polls.choices.create!(answer: "จิโทเกะ")




# Member.last.update_attribute(member_type: 1)


# Member.find_each(&:save)

Rpush::Apns::App
  .create(
    name: 'Pollios', \
    environment: 'sandbox', \
    certificate: "Bag Attributes\n    friendlyName: Apple Push Services: com.pollios.polliosappbeta\n    localKeyID: FF 75 42 8F 42 CF E3 84 E1 DF 5F 92 0D AC 3B 3B EF 15 9A 5A \nsubject=/UID=com.pollios.polliosappbeta/CN=Apple Push Services: com.pollios.polliosappbeta/OU=HVKSRA8F2C/O=POLLIOS COMPANY LIMITED/C=US\nissuer=/C=US/O=Apple Inc./OU=Apple Worldwide Developer Relations/CN=Apple Worldwide Developer Relations Certification Authority\n-----BEGIN CERTIFICATE-----\nMIIGTTCCBTWgAwIBAgIIO6dfjB1bkggwDQYJKoZIhvcNAQELBQAwgZYxCzAJBgNV\nBAYTAlVTMRMwEQYDVQQKDApBcHBsZSBJbmMuMSwwKgYDVQQLDCNBcHBsZSBXb3Js\nZHdpZGUgRGV2ZWxvcGVyIFJlbGF0aW9uczFEMEIGA1UEAww7QXBwbGUgV29ybGR3\naWRlIERldmVsb3BlciBSZWxhdGlvbnMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw\nHhcNMTYwMjI5MDg1NzU2WhcNMTcwMzMwMDg1NzU2WjCBqjEqMCgGCgmSJomT8ixk\nAQEMGmNvbS5wb2xsaW9zLnBvbGxpb3NhcHBiZXRhMTgwNgYDVQQDDC9BcHBsZSBQ\ndXNoIFNlcnZpY2VzOiBjb20ucG9sbGlvcy5wb2xsaW9zYXBwYmV0YTETMBEGA1UE\nCwwKSFZLU1JBOEYyQzEgMB4GA1UECgwXUE9MTElPUyBDT01QQU5ZIExJTUlURUQx\nCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs29o\nCCYuCEfK9Zaz4ljFc++lQNS/uFqBgn/PlYTBK1Lj5l8/MIwaWnvF21hPG/ICmdy4\nBoBAp6ARfNnM1FK6/jbqzhYfs16s/8rZQvnTPvi8MomTYQnyYO3ivZYu8rAW8eEG\nS6HldMr2lYUrMOu329stUjMFQmMnc3cQs4fNQG22FgeU11uMpy4GVOYsMaV8cWpW\nxABt6xkxqFlXIg/Hj8Gy2aw3Ua6dCmB2ujDAKF3p0GKaILKI05w6JVhu4r1iyCPs\npag9GAcB5P7WOxkVvYoLbypuSDfFjmbt7pxeaFbTNlgF9AoVHudcBzIoc5mVCR+m\ns8nvg0Gd0hXNFb0bYwIDAQABo4IChzCCAoMwHQYDVR0OBBYEFP91Qo9Cz+OE4d9f\nkg2sOzvvFZpaMAwGA1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUiCcXCam2GGCL7Ou6\n9kdZxVJUo7cwggEcBgNVHSAEggETMIIBDzCCAQsGCSqGSIb3Y2QFATCB/TCBwwYI\nKwYBBQUHAgIwgbYMgbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRlIGJ5IGFu\neSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBwbGljYWJs\nZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNlcnRpZmlj\nYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRz\nLjA1BggrBgEFBQcCARYpaHR0cDovL3d3dy5hcHBsZS5jb20vY2VydGlmaWNhdGVh\ndXRob3JpdHkwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL2NybC5hcHBsZS5jb20v\nd3dkcmNhLmNybDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwIw\nEAYKKoZIhvdjZAYDAQQCBQAwEAYKKoZIhvdjZAYDAgQCBQAwgZcGCiqGSIb3Y2QG\nAwYEgYgwgYUMGmNvbS5wb2xsaW9zLnBvbGxpb3NhcHBiZXRhMAUMA2FwcAwfY29t\nLnBvbGxpb3MucG9sbGlvc2FwcGJldGEudm9pcDAGDAR2b2lwDCdjb20ucG9sbGlv\ncy5wb2xsaW9zYXBwYmV0YS5jb21wbGljYXRpb24wDgwMY29tcGxpY2F0aW9uMA0G\nCSqGSIb3DQEBCwUAA4IBAQDGuuLZsbb6bWyXoh/2zjKn7EuXw2gMF+orXW6Cp6iA\nhXxolZoYEIxgMD3BI51+gA6UWgbNVDhe4xr0st6iwatkb1CuRh6XV43uda5683+F\ngdMTPuJbNR+Umno0psUDn52gpocDO0TIqTWuOYQReWE5IEx1U9jLqnvUJ3oOO/xe\n/aKWtQDLc/EvOPYADC2zedcRIC3oKrVnLc6++EMBf9RrIHkVL+slCY9VcVgCmxwr\nBT665X7wWwlugbdj3U/Eg2Isx+iW+pfcFMklIqEpPkZYe1ckfpmnqe64bgz6Di2g\nlF2knVmlEDyy3+R+UScwyBwS6iaz/zOD0tPrLnt/xt16\n-----END CERTIFICATE-----\nBag Attributes\n    friendlyName: CodeApp User\n    localKeyID: FF 75 42 8F 42 CF E3 84 E1 DF 5F 92 0D AC 3B 3B EF 15 9A 5A \nKey Attributes: <No Attributes>\n-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAs29oCCYuCEfK9Zaz4ljFc++lQNS/uFqBgn/PlYTBK1Lj5l8/\nMIwaWnvF21hPG/ICmdy4BoBAp6ARfNnM1FK6/jbqzhYfs16s/8rZQvnTPvi8MomT\nYQnyYO3ivZYu8rAW8eEGS6HldMr2lYUrMOu329stUjMFQmMnc3cQs4fNQG22FgeU\n11uMpy4GVOYsMaV8cWpWxABt6xkxqFlXIg/Hj8Gy2aw3Ua6dCmB2ujDAKF3p0GKa\nILKI05w6JVhu4r1iyCPspag9GAcB5P7WOxkVvYoLbypuSDfFjmbt7pxeaFbTNlgF\n9AoVHudcBzIoc5mVCR+ms8nvg0Gd0hXNFb0bYwIDAQABAoIBAH7+6nJaE1po9Yy8\nDLS2f4l+o0cvTEH+TItASntYah9vmz0BTIffoQdJcs+7wMHWl2CuhtCTFS+OatIi\nlIXxx8cEt0sE/YrGB0tDFmIAzzJSeWCLXnPfxlw0AbaNBM1fM94dlYcSHoR64esR\nRXBqZMaGaZ0z3xUNeG6QZpGqG+rsiw5oEVxLjjkv3z5KecUfvhgVMN0ohv0c6KrW\nL3lJsTZOsf0BoQvWSzCqhOk6x8CeOKomIAoaqYIv+xalTn0MCDQ7XvDA8geQNLp4\nNsQ8llbhJ4XRXarsJ1EN2lvyWda+QntNKSxGy8f7G2OtS8ptg7hnvkDs/1I1OV8M\nzJ3qaQECgYEA5/KKYBke7BP/ZL9j7WY7uFk+OsLdycOnqxnHVIsbl+JbvtNN/vs0\n66Up/l4/glnfhhrli/GXJ/rP9nSNzX7tCZRVbucH1y47/vx1wJ2jZ+0d0gZV8NPE\n4r6YUaRLPHLdbE7FO5RAZiuhgXwwAYL9YQyLFI40WwIpo4KRVMnV/3kCgYEAxgrV\nmhg87COSz/R5BFaICYxdgvTlr94gsYTziByZWXI7yQsd2wMS3ZkxlSBWWMPzySBv\nIpTddKUWGoDWydI6HEUBsPvSzj6OAx1Fb1qX4ikhFZthaF7CcAdpWTYzhKKZJC44\nbbBSx1RfLdKTrxDKZcI8I7dQ4F0gvpeKlkLx7rsCgYEApV1iEklWpnFLcASTtblh\ncnkNyM8NWL/JVk82savLrGmRh2cXAGcQv8AtRFDlboWsuuuKJE/FuJc0lT1bq9qG\nHIJItpy4Fk28MHrFaOH6kimXTRl/RAd3I0FHT02W5i3udz1hmKyFjVIl/y8O+sTs\n6LgMoEcSRKAyF4ULICwWCeECgYBWU/K4sUgdR4R/0fnOwkman+1DYK2e9B0cRPBD\nrPPL4dfd01K4XaajolvSvb3mA8UJL3JCiNHgPvZbpz35zAI4wHv0QlGqRepxwRi7\naao7k+IwIQNdE7F+VDy//riGYLqQ4vUGG456BXVX7CskbRVNNlYw24ANzYqwii6H\nQbdkcQKBgQCSzoWX51nJX4jMsBY5kDOdvGB3m1J3cmkNbHjNAIaUSxE0O9GZo1gc\npLpbPdjN4RWBwGHGcyEx6FVHNmnCmLribeneKOpQLmoiNLcWPG0H5sRzV+1BApqJ\n13MuYKrPpC+HO9N+SanU61qh2kaGF86liO97BpurzqPYOtRw8wS3Jw==\n-----END RSA PRIVATE KEY-----\n", \
    password: 'codeapp', \
    connections: 1, \
    type: 'Rpush::Client::ActiveRecord::Apns::App'
  )
