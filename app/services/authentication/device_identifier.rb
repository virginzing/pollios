module Authentication::DeviceIdentifier

  UNKNOWN = 'UNKNOWN'

  APPLE = {
    # 'iPad1,1': 'iPad',
    'iPad2,1': 'iPad 2',
    'iPad2,2': 'iPad 2',
    'iPad2,3': 'iPad 2',
    'iPad2,4': 'iPad 2',
    'iPad2,5': 'iPad mini',
    'iPad2,6': 'iPad mini',
    'iPad2,7': 'iPad mini',
    'iPad3,1': 'iPad 3',
    'iPad3,2': 'iPad 3',
    'iPad3,3': 'iPad 3',
    'iPad3,4': 'iPad 4',
    'iPad3,5': 'iPad 4',
    'iPad3,6': 'iPad 4',
    'iPad4,1': 'iPad Air',
    'iPad4,2': 'iPad Air',
    'iPad4,3': 'iPad Air',
    'iPad4,4': 'iPad mini 2',
    'iPad4,5': 'iPad mini 2',
    'iPad4,6': 'iPad mini 2',
    'iPad4,7': 'iPad mini 3',
    'iPad4,8': 'iPad mini 3',
    'iPad4,9': 'iPad mini 3',
    'iPad5,1': 'iPad mini 4',
    'iPad5,2': 'iPad mini 4',
    'iPad5,3': 'iPad Air 2',
    'iPad5,4': 'iPad Air 2',
    'iPad6,3': 'iPad Pro (9.7 inch)',
    'iPad6,4': 'iPad Pro (9.7 inch)',
    'iPad6,7': 'iPad Pro (12.9 inch)',
    'iPad6,8': 'iPad Pro (12.9 inch)', \
    
    # 'iPhone1,1': 'iPhone',
    # 'iPhone1,2': 'iPhone 3G',
    # 'iPhone2,1': 'iPhone 3GS',
    # 'iPhone3,1': 'iPhone 4',
    # 'iPhone3,2': 'iPhone 4',
    # 'iPhone3,3': 'iPhone 4',
    'iPhone4,1': 'iPhone 4S',
    'iPhone5,1': 'iPhone 5',
    'iPhone5,2': 'iPhone 5',
    'iPhone5,3': 'iPhone 5c',
    'iPhone5,4': 'iPhone 5c',
    'iPhone6,1': 'iPhone 5s',
    'iPhone6,2': 'iPhone 5s',
    'iPhone7,1': 'iPhone 6 Plus',
    'iPhone7,2': 'iPhone 6',
    'iPhone8,1': 'iPhone 6s',
    'iPhone8,2': 'iPhone 6s Plus',
    'iPhone8,4': 'iPhone SE',
    'iPhone9,1': 'iPhone 7',
    'iPhone9,2': 'iPhone 7 Plus',
    'iPhone9,3': 'iPhone 7',
    'iPhone9,4': 'iPhone 7 Plus', \
    
    # 'iPod1,1': 'iPod touch',
    # 'iPod2,1': 'iPod touch 2G',
    # 'iPod3,1': 'iPod touch 3G',
    # 'iPod4,1': 'iPod touch 4G',
    'iPod5,1': 'iPod touch 5G',
    'iPod7,1': 'iPod touch 6G'
  }

  OS = {
    'iPhone OS': 'iOS',
    'iOS': 'iOS'
  }

end
