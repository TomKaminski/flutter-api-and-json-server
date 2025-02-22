import 'dart:async';
import 'package:api_and_json_server/data/database/moor_database.dart';
import 'package:api_and_json_server/services/api_service/api_interface.dart';
import 'package:api_and_json_server/services/database_service/database_interface.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  //TODO: Services should not be inited in contructors, just create them in mapEventToState if needed
  ApiInterface apiService;
  DatabaseInterface databaseService;

  HomeBloc({@required this.apiService, @required this.databaseService})
      : super(HomeLoadingState());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is HomeFetchDataEvent) {
      //TODO: You should yield LoadingState here in case of long api response or low spec device (slow db).
      //TODO: Handle api error here, fallback to database
      yield HomeLoadedState(users: await apiService.fetchData());
    } else if (event is HomeRefreshDataEvent) {
      //TODO: You should yield LoadingState here in case of long api response or low spec device (slow db).
      //TODO: Split this to separate method, now this if else spaghetti code is super ugly.
      //TODO: Use switch on enum values
      //TODO: Switch case only assigning to temp users field, then yield state only once after switch case statements.
      if (event.filter == RefreshEnum.favorites) {
        yield HomeLoadedState(users: await databaseService.getFavoriteUsers());
      } else if (event.filter == RefreshEnum.notFavorites) {
        yield HomeLoadedState(
            users: await databaseService.getNotFavoriteUsers());
      } else if (event.filter == RefreshEnum.alphabetical) {
        yield HomeLoadedState(
            users: await databaseService.getAlphabeticalUsers());
      } else {
        yield HomeLoadedState(users: await databaseService.getAllUsers());
      }
    } else if (event is HomeGetSingleUserEvent) {
      yield HomeLoadedState(
          users: await databaseService.getSingleUser(id: event.id));
    } else if (event is HomeDeleteUserEvent) {
      await databaseService.deleteUser(id: event.id);
      yield HomeLoadedState(users: await databaseService.getAllUsers());
      apiService.deleteUser(id: event.id);
    } else if (event is HomeUpdateIsFavoriteEvent) {
      await databaseService.updateIsFavorite(
          id: event.id, isFavorite: event.isFavorite);
      yield HomeLoadedState(users: await databaseService.getAllUsers());
      apiService.updateIsFavorite(id: event.id, isFavorite: event.isFavorite);
    }
  }
}
