class AttendeesCsvExporter

  # Order of columns must match `header_array`
  def self.attendee_array atnd
    [
      atnd.user_email,
      AttendeeAttributes.values(atnd),
      atnd.guardian_name,
      atnd.shirt_name,
      plan_quantities(atnd)
    ].flatten.map { |v| blank_to_nil(v) }
  end

  # Order must match `attendee_array`
  def self.header_array year
    ['user_email'] + AttendeeAttributes.names + ['guardian', 'shirt_style'] + plan_names(year)
  end

  def self.render year, attendees
    CSV.generate do |csv|
      csv << header_array(year)
      attendees.each do |atnd|
        csv << attendee_array(atnd)
      end
    end
  end

  private

  def self.blank_to_nil obj
    obj.blank? ? nil : obj
  end

  def self.plan_quantities atnd
    pqh = atnd.plan_qty_hash
    plans(atnd.year).map { |p| pqh[p.id].to_i }
  end

  def self.plans year
    Plan.yr(year).alphabetical
  end

  def self.plan_names year
    plans(year).map{ |p| "Plan: " + safe_for_csv(p.name)}
  end

  def self.safe_for_csv(str)
    str.tr(',"', '')
  end

  module AttendeeAttributes
    FIRST_ATRS = %w[aga_id family_name given_name country phone].freeze
    LAST_ATRS = %w[special_request roomate_request].freeze
    INTERNAL_ATRS = %w[id shirt_id user_id understand_minor guardian_attendee_id].freeze

    # It is convenient for name and email to be in the first few
    # columns, and for roommate request to be next to the plans.
    def self.names
      FIRST_ATRS + middle_atrs + LAST_ATRS
    end

    def self.values atnd
      names.map { |atr| value(atnd, atr) }
    end

    private

    def self.middle_atrs
      Attendee.attribute_names - FIRST_ATRS - LAST_ATRS - INTERNAL_ATRS
    end

    def self.value atnd, atr
      if atr == 'rank'
        atnd.rank_name
      else
        atnd[atr]
      end
    end
  end
end
