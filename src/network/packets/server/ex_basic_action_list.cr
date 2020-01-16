# class Packets::Outgoing::ExBasicActionList < GameServerPacket
#   initializer actions: Slice(Int32)

#   private def write_impl
#     c 0xfe
#     h 0x5f

#     d @actions.size
#     @actions.each { |id| d id }
#   end

#   ACTIONS_ON_TRANSFORM = Int32.slice(
#     1, 2, 3, 4,
#     5, 6, 7, 8,
#     9, 11, 15, 16,
#     17, 18, 19, 21,
#     22, 23, 32, 36,
#     39, 40, 41, 42,
#     43, 44, 45, 46,
#     47, 48, 50, 52,
#     53, 54, 55, 56,
#     57, 63, 64, 65,
#     70, 1000, 1001, 1003,
#     1004, 1005, 1006, 1007,
#     1008, 1009, 1010, 1011,
#     1012, 1013, 1014, 1015,
#     1016, 1017, 1018, 1019,
#     1020, 1021, 1022, 1023,
#     1024, 1025, 1026, 1027,
#     1028, 1029, 1030, 1031,
#     1032, 1033, 1034, 1035,
#     1036, 1037, 1038, 1039,
#     1040, 1041, 1042, 1043,
#     1044, 1045, 1046, 1047,
#     1048, 1049, 1050, 1051,
#     1052, 1053, 1054, 1055,
#     1056, 1057, 1058, 1059,
#     1060, 1061, 1062, 1063,
#     1064, 1065, 1066, 1067,
#     1068, 1069, 1070, 1071,
#     1072, 1073, 1074, 1075,
#     1076, 1077, 1078, 1079,
#     1080, 1081, 1082, 1083,
#     1084, 1089, 1090, 1091,
#     1092, 1093, 1094, 1095,
#     1096, 1097, 1098
#   )

#   def self.default_list
#     new(DEFAULT_ACTION_LIST)
#   end

#   DEFAULT_ACTION_LIST = Slice(Int32).new(189)
#   0.upto(73) { |i| DEFAULT_ACTION_LIST[i] = i }
#   (1000..1098).each_with_index { |i, j| DEFAULT_ACTION_LIST[j + 74] = i }
#   (5000..5015).each_with_index { |i, j| DEFAULT_ACTION_LIST[j + 74 + 99] = i }

#   # DEFAULT_LIST = new(DEFAULT_ACTION_LIST)
# end




class Packets::Outgoing::ExBasicActionList < GameServerPacket
  initializer actions : Array(Int32) | Slice(Int32)

  private def write_impl
    c 0xfe
    h 0x5f

    d @actions.size
    @actions.each { |id| d id }
  end

  ACTIONS_ON_TRANSFORM = {
    1, 2, 3, 4,
    5, 6, 7, 8,
    9, 11, 15, 16,
    17, 18, 19, 21,
    22, 23, 32, 36,
    39, 40, 41, 42,
    43, 44, 45, 46,
    47, 48, 50, 52,
    53, 54, 55, 56,
    57, 63, 64, 65,
    70, 1000, 1001, 1003,
    1004, 1005, 1006, 1007,
    1008, 1009, 1010, 1011,
    1012, 1013, 1014, 1015,
    1016, 1017, 1018, 1019,
    1020, 1021, 1022, 1023,
    1024, 1025, 1026, 1027,
    1028, 1029, 1030, 1031,
    1032, 1033, 1034, 1035,
    1036, 1037, 1038, 1039,
    1040, 1041, 1042, 1043,
    1044, 1045, 1046, 1047,
    1048, 1049, 1050, 1051,
    1052, 1053, 1054, 1055,
    1056, 1057, 1058, 1059,
    1060, 1061, 1062, 1063,
    1064, 1065, 1066, 1067,
    1068, 1069, 1070, 1071,
    1072, 1073, 1074, 1075,
    1076, 1077, 1078, 1079,
    1080, 1081, 1082, 1083,
    1084, 1089, 1090, 1091,
    1092, 1093, 1094, 1095,
    1096, 1097, 1098
  }

  DEFAULT_ACTION_LIST = Slice(Int32).new(189)
  0.upto(73) { |i| DEFAULT_ACTION_LIST[i] = i }
  (1000..1098).each_with_index { |i, j| DEFAULT_ACTION_LIST[j + 74] = i }
  (5000..5015).each_with_index { |i, j| DEFAULT_ACTION_LIST[j + 74 + 99] = i }

  DEFAULT_LIST = new(DEFAULT_ACTION_LIST)
  ON_TRANSFORM = new(ACTIONS_ON_TRANSFORM)
end
