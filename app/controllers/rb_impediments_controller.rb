#-- copyright
# OpenProject Backlogs Plugin
#
# Copyright (C)2013-2014 the OpenProject Foundation (OPF)
# Copyright (C)2011 Stephan Eckardt, Tim Felgentreff, Marnen Laibow-Koser, Sandro Munda
# Copyright (C)2010-2011 friflaj
# Copyright (C)2010 Maxime Guilbot, Andrew Vit, Joakim Kolsjö, ibussieres, Daniel Passos, Jason Vasquez, jpic, Emiliano Heyns
# Copyright (C)2009-2010 Mark Maglana
# Copyright (C)2009 Joe Heck, Nate Lowrie
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License version 3.
#
# OpenProject Backlogs is a derivative work based on ChiliProject Backlogs.
# The copyright follows:
# Copyright (C) 2010-2011 - Emiliano Heyns, Mark Maglana, friflaj
# Copyright (C) 2011 - Jens Ulferts, Gregor Schmidt - Finn GmbH - Berlin, Germany
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class RbImpedimentsController < RbApplicationController
  def create
    @impediment = Impediment.create_with_relationships(impediment_params(Impediment.new), @project.id)
    status = (@impediment.errors.empty? ? 200 : 400)
    @include_meta = true

    respond_to do |format|
      format.html { render partial: 'impediment', object: @impediment, status: status }
    end
  end

  def update
    @impediment = Impediment.find(params[:id])
    result = @impediment.update_with_relationships(impediment_params(@impediment))
    status = (result ? 200 : 400)
    @include_meta = true

    respond_to do |format|
      format.html { render partial: 'impediment', object: @impediment, status: status }
    end
  end

private

  def impediment_params(instance)
    # We do not need project_id, since ApplicationController will take care of
    # fetching the record.
    params.delete(:project_id)

    hash = params.permit(:fixed_version_id, :status_id, :id, :prev, :sprint_id,
                         :assigned_to_id, :remaining_hours, :subject, :blocks_ids)

    # We block block_ids only when user is not allowed to create or update the
    # instance passed.
    unless instance && ((instance.new_record? && User.current.allowed_to?(:create_impediments, @project)) || User.current.allowed_to?(:update_impediments, @project))
      hash.delete(:block_ids)
    end

    hash
  end
end
