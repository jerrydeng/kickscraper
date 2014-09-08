module Kickscraper
    class User < Api
    	attr_accessor :backed_projects, :starred_projects

    	def to_s
    		name
    	end

        def reload!
            @raw = Kickscraper.client.process_api_url("User", self.urls.api.user, false)
            Kickscraper::User::do_coercion(self)
        end
        
        def biography
            reload! unless @raw['biography']
            @raw['biography']
        end

        def backed_projects
        	return [] unless self.urls.api.backed_projects
            if @backed_projects
                return @backed_projects 
            else
                projects = Kickscraper.client.process_api_url("Projects", self.urls.api.backed_projects)
                projects = load_more_backed_projects(projects)
                return @backed_projects ||= projects
            end
        end

        def starred_projects
        	return [] unless self.urls.api.starred_projects
            @starred_projects ||= Kickscraper.client.process_api_url("Projects", self.urls.api.starred_projects)
        end
        
        def created_projects
            return [] unless self.urls.api.created_projects
            @created_projects ||= Kickscraper.client.process_api_url("Projects", self.urls.api.created_projects)
        end

        def load_more_backed_projects(projects = [])
            more_url = Kickscraper.client.more_user_projects_url
            if more_url
                more_projects = Kickscraper.client.process_api_url("Projects", Kickscraper.client.more_user_projects_url)
                if more_projects.empty?                    
                    Kickscraper.client.more_user_projects_url = nil
                    return projects
                else
                    return load_more_backed_projects(projects + more_projects)
                end
            else
                return projects
            end
        end
    end
end