class Api::V1::ProfilesController < Api::V1::BaseController
  authorize_resource class: false

  def me
    render json: current_user
  end
end
