module Mongoid::History
  class Sweeper < Mongoid::Observer
    def controller
      Thread.current[:mongoid_history_sweeper_controller]
    end

    def controller=(value)
      Thread.current[:mongoid_history_sweeper_controller] = value
    end

    def self.observed_classes
      [Mongoid::History.tracker_class]
    end

    def around(controller)
      self.controller = controller
      yield
    ensure
      self.controller = nil
    end

    def before_create(track)
      modifier_field = track.trackable.history_trackable_options[:modifier_field]
      modifier = track.trackable.send modifier_field
      track.modifier = current_user unless modifier
    end

    def current_user
      if controller.respond_to?(Mongoid::History.current_user_method, true)
        controller.send Mongoid::History.current_user_method
      end
    end
  end
end
