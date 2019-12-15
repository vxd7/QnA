class FilesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_file

  def destroy
    @resource = @file.record
    if current_user.author_of?(@resource)
      @file.purge
      @resource.reload
    end
  end

  private

  def load_file
    @file = ActiveStorage::Attachment.find(params[:id])
  end
end
