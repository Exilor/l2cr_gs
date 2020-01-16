require "./object_known_list"

class CharKnownList < ObjectKnownList
  def known_players : IHash(Int32, L2PcInstance)
    @known_players || sync do
      @known_players ||= Concurrent::Map(Int32, L2PcInstance).new
    end
  end

  def known_summons : IHash(Int32, L2Summon)
    @known_summons || sync do
      @known_summons ||= Concurrent::Map(Int32, L2Summon).new
    end
  end

  def known_relations : IHash(Int32, Int32)
    @known_relations || sync do
      @known_relations ||= Concurrent::Map(Int32, Int32).new
    end
  end

  def add_known_object(object : L2Object) : Bool
    return false unless super

    if object.is_a?(L2PcInstance)
      known_players[object.l2id] = object
      known_relations[object.l2id] = -1
    elsif object.is_a?(L2Summon)
      known_summons[object.l2id] = object
    end

    true
  end

  def knows_player?(pc : L2PcInstance) : Bool
    return true if @active_object == pc
    known_players = @known_players
    !!known_players && known_players.has_key?(pc.l2id)
  end

  def remove_all_known_objects
    super

    @known_players.try &.clear
    @known_summons.try &.clear
    @known_relations.try &.clear

    char = active_char
    char.target = nil
    if char.ai?
      char.ai = nil
    end
  end

  def remove_known_object(object : L2Object?, forget : Bool) : Bool
    return false unless super

    unless forget
      if object.player?
        @known_players.try &.delete(object.l2id)
        @known_relations.try &.delete(object.l2id)
      elsif object.summon?
        @known_summons.try &.delete(object.l2id)
      end
    end

    if object == active_char.target
      active_char.target = nil
    end

    true
  end

  def forget_objects(full_check : Bool)
    unless full_check
      @known_players.try &.each do |id, pc|
        dst = get_distance_to_forget_object(pc)
        if !pc.visible? || !Util.in_short_radius?(dst, @active_object, pc, true)
          @known_players.try &.delete(id)
          remove_known_object(pc, true)
          @known_relations.try &.delete(id)
          @known_objects.try &.delete(id)
        end
      end

      @known_summons.try &.each do |id, s|
        next if @active_object.player? && s.owner == @active_object
        dst = get_distance_to_forget_object(s)
        if !s.visible? || !Util.in_short_radius?(dst, @active_object, s, true)
          @known_summons.try &.delete(id)
          remove_known_object(s, true)
          @known_objects.try &.delete(id)
        end
      end

      return
    end

    me = @active_object
    @known_objects.try &.each do |id, o|
      dst = get_distance_to_forget_object(o)
      if !o.visible? || !Util.in_short_radius?(dst, me, o, true)
        @known_objects.try &.delete(id)
        remove_known_object(o, true)
        if o.player?
          @known_players.try &.delete(id)
          @known_relations.try &.delete(id)
        elsif o.summon?
          @known_summons.try &.delete(id)
        end
      end
    end
  end

  def each_character(& : L2Character ->) : Nil
    @known_objects.try &.each_value do |object|
      if object.is_a?(L2Character)
        yield object
      end
    end
  end

  def each_character(radius : Int32, & : L2Character ->) : Nil
    char = active_char
    each_character do |object|
      if Util.in_range?(radius, char, object, true)
        yield object
      end
    end
  end

  def each_player(radius : Int32, & : L2PcInstance ->) : Nil
    char = active_char
    @known_players.try &.each_value do |pc|
      if Util.in_range?(radius, char, pc, true)
        yield pc
      end
    end
  end

  def active_char : L2Character
    active_object.as(L2Character)
  end
end
