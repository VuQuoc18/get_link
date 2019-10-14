class LinksController < ApplicationController
    protect_from_forgery :except => [:get_link_artlist, :get_link_emvn]
    require 'watir-webdriver'
    def index
        @link = Link.all
    end

    def get_link_artlist
        opts = {
            headless: true
        }

        if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
        opts.merge!( options: {binary: chrome_bin})
        end 

        url = params[:url]
        if url.empty?
            render json: {message: "Error", result: "error"} and return
        end
        page = Watir::Browser.new :chrome, opts
        page.goto(url)
        link = page.execute_script('return $(".bottom-player").attr("data-href")')
        if link.nil?
            page.quit
            render json: {message: "Link error", result: "error"} and return
        else
            page.quit
            render json: {message: "Success", result: "success", link: link} and return
        end
    end

    def get_link_emvn
        opts = {
            headless: true
        }

        if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
        opts.merge!( options: {binary: chrome_bin})
        end 

        url = params[:url]
        if url.empty?
            render json: {message: "Error", result: "error"} and return
        end
        page = Watir::Browser.new :chrome, opts
        page.goto(url)
        load_done = page.div(id: "waveform_container").wait_until(&:present?)
        id_url = url[(url.index("=") + 1)..-1]
        page.div(:id => "track_list_#{id_url}_play_button_details_page").fire_event :click
        sleep(0.5)
        link = page.audio.attribute_value("src")
        if link.nil?
            page.quit
            render json: {message: "Link error", result: "error"} and return
        else
            page.quit
            render json: {message: "Success", result: "success", link: link} and return
        end
    end

    def check_link
        url = params[:url]
        if url.empty?
            render json: {message: "Url can not be nil", result: "error"} and return
        else
            unless url.include?("epicmusicvn.sourceaudio.com") || url.include?("artlist.io")
                render json: {message: "Only support epicmusicvn & artlist", result: "error"} and return
            else
                render json: {message: "ok", result: "ok"} and return
            end
        end
    end
end