      program checkin_trends

          implicit none

          integer iline, place_index
          integer nbins, time_bin, interval, maxtime
          parameter ( nbins = 20, interval = 40000 )

          integer headers(nbins), ihead

c         variables for reading means, medians and std files
          integer nplaces
          parameter ( nplaces = 108390 )
          character(len=10) place_list(nplaces)
          integer counts(nbins, nplaces)

c         variables for stepping through samples file
          integer num, row_id
          double precision place_x, place_y
          double precision accuracy
          integer time
          character(len=10) place

c         ----------------------------------

c         get std of positions for each place_id group
          open(unit = 70,
     &      file = '../Data/place_id_counts.csv',
     &      action = 'read')
c         throw away headers line
          read(70,*)
c         just get list of places 
          do iline = 1, nplaces
            read(70,*) place_list(iline) 
          enddo

          close(70)

c         open samples file for reading
          open(unit = 71, 
     &      file = '../Data/train.csv',
     &      action = 'read')

c         initialize all counts to 0
          counts = 0

c         step through samples file and process each line
c         throw away headers line
          read(71,*)
c         do iline = 1,29118023
          do iline = 1,1000

            read(71, *, end=100) row_id, place_x, place_y, 
     &                           accuracy, time, place

c           keep track of maximum time in data set
            maxtime = max(time, maxtime)
c           lookup place row
            call lookup(place_list, nplaces, place, place_index)

c           determine time bin
            time_bin = time / interval + 1

            counts(time_bin, place_index) = 
     &                       counts(time_bin,place_index) + 1
          
          enddo

 100      continue  

          close(71)

c         write result to csv file

          open(unit = 80,
     &      file = 'checkin_trends.csv', 
     &      action = 'write')

c         write headers to csv file
          do ihead = 1, nbins
            headers(ihead) = (ihead-1) * interval
          enddo
          write(80, fmt="(*(g0:','))") 'place_id', headers

c         loop over places
          do iline = 1, nplaces
            write(80, fmt="(*(g0:','))") place_list(iline),
     &                                   counts(:,iline)
          enddo

          close(80)

      end program checkin_trends


      subroutine lookup(place_list, list_length, place, place_index)

          implicit none

          integer list_length
          character(len=10) place_list(list_length)
          character(len=10) place
          integer place_index
          
          integer ii

          place_index = 0
          ii = 1
          do while (place_index.eq.0)
            if (place_list(ii).eq.place) then
              place_index = ii                
            endif
            ii = ii + 1
          enddo

          return
      end subroutine lookup

