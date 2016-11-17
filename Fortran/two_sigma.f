      program two_sigma

          implicit none

          integer iline, index

c         variables for reading means, medians and std files
          integer nplaces
          parameter ( nplaces = 108390 )
          double precision place_x_list(nplaces), place_y_list(nplaces)
          double precision std_x_list(nplaces), std_y_list(nplaces)
          double precision counts_list(nplaces)
          double precision tod_list(4,nplaces)
          double precision acc_list(nplaces) 
          character(len=10) place_list(nplaces)

c         variables for stepping through samples file
          integer num, row_id
          double precision place_x, place_y
          double precision accuracy
          integer time
          character(len=10) place

c         variables for collecting distances
          integer nneighbours
          parameter ( nneighbours = 80 )
          character(len=10) neighbours(nneighbours)
          double precision dists(nneighbours)
          integer ncandidates

c         processing test file flag
          integer testing

c         ----------------------------------

          testing = 0

          if (.false.) then
c           read coordinates of place_id names, mean positions
c           and timesofday
            open(unit = 70,
     &          file = '../Data/place_id_means_tod.csv',
     &          action = 'read')
c           throw away headers line
            read(70,*)
            do iline = 1, nplaces
                read(70,*) place_list(iline), 
     &                     place_x_list(iline), place_y_list(iline),
     &                     acc_list(iline), 
     &                     tod_list(:,iline)
            enddo
            close(70)
          endif

c         actually we want the median positions!!
          open(unit = 70,
     &      file = '../Data/place_id_medians.csv',
     &      action = 'read')
c         throw away headers line
          read(70,*)
          do iline = 1, nplaces
            read(70,*) place_list(iline), 
     &                 place_x_list(iline), place_y_list(iline)
          enddo
          close(70)

c         get std of positions for each place_id group
          close(70)
          open(unit = 70,
     &      file = '../Data/place_id_stds.csv',
     &      action = 'read')
c         throw away headers line
          read(70,*)
          do iline = 1, nplaces
            read(70,*) place_list(iline), 
     &                 std_x_list(iline), std_y_list(iline)
          enddo

          close(70)

          if (testing.eq.1) then

c             open samples file for reading
              open(unit = 71, 
     &          file = '../Data/test.csv',
     &          action = 'read')

c             open neighbourhoods and distances files for writing
              open(unit = 80, 
     &          file = 'test_two_sigma_neighbours.csv', 
     &          action = 'write')
              open(unit = 81, 
     &          file = 'test_two_sigma_dists.csv', 
     &          action = 'write')

          else

c             open samples file for reading
              open(unit = 71, 
     &          file = '../Data/train.csv',
     &          action = 'read')

c             open neighbourhoods and distances files for writing
              open(unit = 80, 
     &          file = 'train_two_sigma_neighbours.csv', 
     &          action = 'write')
              open(unit = 81, 
     &          file = 'train_two_sigma_dists.csv', 
     &          action = 'write')

          end if

c         write headers to csv files
          write(80, *) 'row_id,place_id'
          write(81, *) 'row_id,distances'

c         step through samples file and process each line
c         throw away headers line
          read(71,*)
c         do iline = 1,29118023
          do iline = 1,10000

c             print *, ' '
c             print *, 'processing ', iline

c            if (modulo(iline,20000).eq.0) then
c                print *, iline, ' . . .'
c            end if

c           testing file has no "place_id" column!
            if (testing.eq.1) then
                read(71, *, end=100) row_id, place_x, place_y, 
     &                               accuracy, time
            else
                read(71, *, end=100) row_id, place_x, place_y, 
     &                               accuracy, time, place
            endif

            call nearest(place_list, place_x_list, place_y_list,
     &                   std_x_list, std_y_list,
     &                   nplaces, place_x, place_y,
     &                   nneighbours, neighbours, dists, 
     &                   ncandidates)

            write(80, fmt="(1(g0:','),*(g0:' '))")
     &                        row_id,neighbours(1:ncandidates)
            write(81, fmt="(1(g0:','),*(f12.10:' '))") 
     &                        row_id,dists(1:ncandidates)

          enddo
 100      continue  

          close(71)
          close(80)
          close(81)
      end program two_sigma


      subroutine dist(x1, y1, x2, y2, d)
          implicit none
          double precision x1, y1, x2, y2, d

          d = (x2-x1)**2 + (y2-y1)**2

          return

      end subroutine dist

      subroutine timeofday(time, period, todblock)

          implicit none

          integer time, period, todblock
          integer resid

          resid = modulo(time, period)

          if ((resid.ge.1000).and.(resid.lt.3500)) then
              todblock = 1
          else if ((resid.ge.3500).and.(resid.lt.6000)) then
              todblock = 2
          else if ((resid.ge.6000).and.(resid.lt.8500)) then
              todblock = 3
          else
              todblock = 4
          endif
          
          return
      end subroutine timeofday


      subroutine nearest(place_list, place_x_list, place_y_list,
     &                   std_x_list, std_y_list,
     &                   list_length, place_x, place_y,
     &                   nn, neighbours, dists, ncandidates)

          implicit none

          integer list_length, nplaces
          double precision place_x, place_y
          double precision place_x_list(list_length), 
     &                     place_y_list(list_length)
          double precision std_x_list(list_length),
     &                     std_y_list(list_length)
          character(len=10) place_list(list_length)

          integer nn
          character(len=10) neighbours(nn)
          double precision dists(nn)
          double precision d

          integer irow, ineighbour, jneighbour
          integer ncandidates

          double precision sx, sy, sxmax, symax
          
          ncandidates = 0

          sxmax = 7.5d-1
          symax = 2.5d-2

          do irow = 1,list_length

            sx = min(std_x_list(irow),sxmax)
            sy = min(std_y_list(irow),symax)

            if (((place_x_list(irow)-sx).le.(place_x))
     &           .and.
     &          ((place_x_list(irow)+sx).ge.(place_x))
     &           .and.
     &          ((place_y_list(irow)-sy).le.(place_y))
     &           .and.
     &          ((place_y_list(irow)+sy).ge.(place_y)))
     &      then
              
              if (ncandidates.lt.nn) then
                  
                  ncandidates = ncandidates+1
                  neighbours(ncandidates) = place_list(irow)

                  call dist(place_x,place_y,
     &                      place_x_list(irow),place_y_list(irow),
     &                      d)

                  dists(ncandidates) = d

              else
                  print *, 'neighbourhood full dude! irow = ',irow
                  exit
              endif

            endif

          enddo

      end subroutine nearest


