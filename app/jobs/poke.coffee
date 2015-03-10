DEBUG = false
DEEP = 5

jquery = require 'jquery'
phantom = require 'phantom'

poke = {
  data: [],
  login: (email, password) ->
  visit: (url) ->
  run: (rules, callback) ->
    phantom.create { parameters: { 'ignore-ssl-errors': 'yes' } }, (ph) ->
      ph.createPage (page) ->
        url = "https://www.linkedin.com/vsearch/p?keywords=#{rules.keywords}&f_G=#{rules.location_params}&f_I=#{rules.industry_params}&f_N=#{rules.position_params}"
        page.set 'settings',
          userAgent: 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
          loadImages: false
          javascriptEnabled: true
          loadPlugins: true
          localToRemoteUrlAccessEnabled: true
        page.set 'viewportSize',
          width: 680
          height: 480
        page.set 'onConsoleMessage', (msg) ->
          console.log "message: #{msg}"
          return

        # Login
        page.open 'https://www.linkedin.com/uas/login', (status) ->
          if status is 'success'
            email = rules.user.email
            password = rules.user.password
            page.evaluate (email, password) ->
              document.querySelector('#session_key-login').value = "#{email}"
              document.querySelector('#session_password-login').value = "#{password}"
              document.querySelector('#login').submit()
              return
            , null, email, password
            page.render "public/img/screenshots/#{rules.name}-01-login.png" if DEBUG
            setTimeout (->
              page.render "public/img/screenshots/#{rules.name}-02-home.png" if DEBUG
              i = 1

              # Search
              search = setInterval (->
                console.log "step #1: open url #{url}&page_num=#{i}" if DEBUG
                page.open "#{url}&page_num=#{i}", (status) ->
                  if status is 'success'

                    page.evaluate (->
                      data = {}
                      j = 0
                      if $('li.result.people').length is 0
                        console.log "step #1: no result" if DEBUG
                        clearInterval ping
                      $('li.result.people').each (index, el) ->
                        lnk = $(el).find('a.title')
                        unless lnk is undefined
                          uid = $(el).data('li-entity-id')
                          data[j] = {
                            uid: uid
                            name: "#{lnk.text()}"
                            linkedin_url: "https://www.linkedin.com/profile/view?id=#{uid}"
                            visited_at: Date.now()
                          }
                          j++
                      data
                    ), (data) ->

                      k = 0
                      # Ping
                      ping = setInterval (->
                        unless data is null
                          unless data[k] is undefined
                            console.log "step #2: open url #{data[k].linkedin_url}" if DEBUG
                            page.open data[k].linkedin_url, (status) ->
                              if status == 'success'
                                unless data[k] is undefined
                                  data[k].visited_at = Date.now()
                                  page.render "public/img/screenshots/#{rules.name}-03-opening-#{data[k].uid}.png" if DEBUG
                              else
                                console.log "step #3: error opening url #{page.reason_url} : #{page.reason}" if DEBUG
                                page.render "public/img/screenshots/#{rules.name}-03-error-opening-#{data[k].uid}.png" if DEBUG
                          else
                            clearInterval ping
                        else
                          clearInterval ping
                        unless data is null
                          if k is data.length
                            clearInterval ping
                          k++
                      ), 7000

                      poke.data.push data

                    page.render "public/img/screenshots/#{rules.name}-02-search-result-page-#{i-1}.png" if DEBUG
                  else
                    console.log "step #2: error opening url #{page.reason_url} : #{page.reason}" if DEBUG
                    page.render "public/img/screenshots/#{rules.name}-01-#{i}-error-opening-url.png" if DEBUG

                if i > DEEP
                  clearInterval search
                  callback poke.data
                  ph.exit
                i++

              ), 81000
            ), 7000

          else
            console.log "step #1: error opening url #{page.reason_url} : #{page.reason}" if DEBUG
            page.render "public/img/screenshots/#{rules.name}-99-error-opening-url.png" if DEBUG
}

module.exports = poke
