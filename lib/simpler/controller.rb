require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @env = env
      @env['simpler.content-type'] = []
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @request.env['simpler.params'].merge!(@request.params)
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_status_post_request
      set_default_headers
      send(action)
      write_response
      @env['simpler.content-type'] << @response['Content-Type']

      @response.finish
    end

    def params
      @request.env['simpler.params']
    end

  private

    def set_status_post_request
     @response.status = 201 if @request.post?
    end

    def extract_name
     self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body
      @response.write(body)
    end

    def render_body
      if @request.env['simpler.template'].class == Hash
        @response['Content-Type'] = 'text/plain'
        return @request.env['simpler.template'].values.last
      else
        View.new(@request.env).render(binding)
      end
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

  end
end
