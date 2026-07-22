import 'package:flutter/material.dart';


class PaginationController<T> {
  final Future<dynamic> Function({int? page, int? pageSize}) onLoadMore;
  final int pageSize;
  final double threshold;
  final bool isInverse;
  final bool _fromBloc;
  final List<T> Function()? _getItems;
  final ScrollController scrollController;
  PaginationController({
    this.threshold = 100,
    required this.pageSize,
    required this.scrollController,
    required Future<List<T>> Function({int? page, int? pageSize}) this.onLoadMore,
    this.onUpdate,
    this.isInverse = false,
  }):_fromBloc=false,items=[],_getItems=null;

  PaginationController.bloc({
    this.threshold = 100,
    required this.pageSize,
    required this.scrollController,
   required Future<void> Function({int? page, int? pageSize}) this.onLoadMore,
    required List<T> Function() items,
    this.isInverse = false,
  }):_getItems =items,items=[],
        _fromBloc=true,onUpdate=null;

  void Function()? onUpdate;
  int page = 0;
   late int currentPageSize=pageSize;
  bool isLoading = false;
  bool hasMore = true;
  int _lastItemsLength = 0;
  final List<T> items;
  List<T> get list =>_fromBloc?_getItems!(): items;
  int get itemCountWithLoading => list.length+ (isLoading ? currentPageSize : 0);

  Future<void> init() async {
    await getMore(page, currentPageSize);
    double lastScroll = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkAndGetUntilFillScreen();
      scrollController.addListener(() async {
        double currentScroll = isInverse
            ? scrollController.position.maxScrollExtent -
            scrollController.position.pixels
            : scrollController.position.pixels;
        final isArrive = currentScroll >=
            scrollController.position.maxScrollExtent - threshold &&
            (currentScroll - lastScroll).abs() > 50;
        if (isArrive && !isLoading && hasMore) {
          lastScroll = currentScroll;
          await getMore(page, currentPageSize);
        }
      });
    });
  }

  // Future<void> initWithSuperSliver(ListController listController) async {
  //   await getMore();
  //   double lastExtent = 0;
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     listController.addListener(() async {
  //       print("isAttached===${listController.isAttached}\n"
  //           "isLoading $isLoading hasMore $hasMore");
  //       if (listController.isAttached && !isLoading && hasMore) {
  //         final visibleRange = listController.visibleRange;
  //         if (visibleRange != null) {
  //           final (firstVisible, lastVisible) = visibleRange;
  //           if (lastVisible >= items.length - currentPageSize &&
  //               lastExtent != listController.totalExtent) {
  //             lastExtent = listController.totalExtent;
  //             await getMore(page, currentPageSize);
  //           }
  //         }
  //       }
  //     });
  //   });
  // }


  Future<void> getMore([int? newPage, int? currentPageSize]) async {
    newPage ??= page;
    currentPageSize ??= this.currentPageSize;
    print(
      "--------------------Before-----------------\n"
          "Page=$page currentPageSize=$currentPageSize total=${items
          .length} hasMore=$hasMore\n"
          "--------------------------------------------",
    );
    if (isLoading || !hasMore) return;
    isLoading = true;
    if (newPage == 0) {
      _lastItemsLength = 0;
    } else {
      _lastItemsLength = list.length;
    }


    final result = await onLoadMore(page: newPage, pageSize: currentPageSize);

    if (!_fromBloc&&result is List<T>) {
      if (result.isEmpty) {
        hasMore = false;
      } else {
        items.addAll(result);
        onUpdate?.call();
      }
      update();
    }

  }
  void update(){
    isLoading = false;
    final items =list;
    if (items.length <= _lastItemsLength) {
      hasMore = false;
    } else {
      page = ((items.length / currentPageSize)).ceil();
      if (items.isEmpty||items.length < (page*currentPageSize)) {
        hasMore = false;
      }
    }

    print(
      "--------------------After-----------------\n"
          "Page=$page currentPageSize=$currentPageSize total=${items
          .length} hasMore=$hasMore\n"
          "--------------------------------------------",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndGetUntilFillScreen();
    });
  }
  void changePageSize(int newSize,{bool getRemaining=false}){
      final deffrent = newSize - currentPageSize;
      currentPageSize = newSize;
      if (deffrent > 0 && getRemaining) {
         getMore(page, deffrent);
      }

  }
  void _checkAndGetUntilFillScreen() {
    if (!scrollController.hasClients) return;
    try {
      final position = scrollController.position;
      if (position.maxScrollExtent <= 0 && hasMore && !isLoading) {
        getMore(page, currentPageSize);
      }
    } catch (_) {}
  }
  

  Future<void> getRemaining([int? total]) async {
    final offset = page * this.currentPageSize;
    final currentPageSize = total != null ? total - items.length : null;
    //todo offset mean start =>send to isar not here page = 0.5
    await getMore(page, currentPageSize);
  }

  Future<void> getAllLooping() async {
    if (hasMore) {
      await getMore();
    } else {
      return;
    }
  }

  Future<void> refreshAndGetAll() async {
    print("has more $hasMore refreshAndGetAll");
    if (hasMore) {
      await getMore(page * currentPageSize, null);
    } else {
      return;
    }
  }



  Future<void> refresh() async {
    if(!_fromBloc) {
      items.clear();
    }
    page = 0;
    isLoading = false;
    hasMore = true;
    await getMore(page, currentPageSize);
  }

  void add(T item) => items.add(item);

  void addAll(List<T> list) => items.addAll(list);

  void insert(int index, T item) => items.insert(index, item);

  void updateWhere(T item, bool Function(T element) where) {
    final index = items.indexWhere(where);
    items[index] = item;
    onUpdate?.call();
  }

  void removeWhere(bool Function(T element) where) => items.removeWhere(where);

  void clear() {
    items.clear();
    hasMore = true;
    isLoading = false;
    page = 0;
    _lastItemsLength = 0;
  }
  void dispose(){
    clear();
    scrollController.dispose();
  }
}
