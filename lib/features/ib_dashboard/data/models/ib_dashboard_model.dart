class IbDashboardResponse {
  final bool done;
  final List<IbReferralItem> list;
  final int count;
  final IbDashboardTotals totals;
  final IbDashboardKpis kpis;

  IbDashboardResponse({
    required this.done,
    required this.list,
    required this.count,
    required this.totals,
    required this.kpis,
  });

  factory IbDashboardResponse.fromJson(Map<String, dynamic> json) {
    return IbDashboardResponse(
      done: json['done'] ?? false,
      list: (json['list'] as List?)?.map((e) => IbReferralItem.fromJson(e)).toList() ?? [],
      count: json['count'] ?? 0,
      totals: IbDashboardTotals.fromJson(json['totals'] ?? {}),
      kpis: IbDashboardKpis.fromJson(json['kpis'] ?? {}),
    );
  }
}

class IbReferralItem {
  final num? id;
  final String? name;
  final String? email;
  final bool isIb;
  final num level;
  final bool direct;
  final num accountCount;
  final num balance;
  final num credit;
  final num equity;
  final num deposits;
  final num withdrawals;
  final num netDeposits;
  final num lots;
  final num pnl;

  IbReferralItem({
    this.id,
    this.name,
    this.email,
    this.isIb = false,
    this.level = 0,
    this.direct = false,
    this.accountCount = 0,
    this.balance = 0,
    this.credit = 0,
    this.equity = 0,
    this.deposits = 0,
    this.withdrawals = 0,
    this.netDeposits = 0,
    this.lots = 0,
    this.pnl = 0,
  });

  factory IbReferralItem.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) => val is num ? val : num.tryParse(val?.toString() ?? '') ?? 0;
    
    return IbReferralItem(
      id: parseNum(json['id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      isIb: json['isIb'] ?? false,
      level: parseNum(json['level']),
      direct: json['direct'] ?? false,
      accountCount: parseNum(json['accountCount']),
      balance: parseNum(json['balance']),
      credit: parseNum(json['credit']),
      equity: parseNum(json['equity']),
      deposits: parseNum(json['deposits']),
      withdrawals: parseNum(json['withdrawals']),
      netDeposits: parseNum(json['netDeposits']),
      lots: parseNum(json['lots']),
      pnl: parseNum(json['pnl']),
    );
  }
}

class IbDashboardTotals {
  final num balance;
  final num credit;
  final num equity;
  final num deposits;
  final num withdrawals;
  final num netDeposits;
  final num lots;
  final num pnl;

  IbDashboardTotals({
    this.balance = 0,
    this.credit = 0,
    this.equity = 0,
    this.deposits = 0,
    this.withdrawals = 0,
    this.netDeposits = 0,
    this.lots = 0,
    this.pnl = 0,
  });

  factory IbDashboardTotals.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) => val is num ? val : num.tryParse(val?.toString() ?? '') ?? 0;
    return IbDashboardTotals(
      balance: parseNum(json['balance']),
      credit: parseNum(json['credit']),
      equity: parseNum(json['equity']),
      deposits: parseNum(json['deposits']),
      withdrawals: parseNum(json['withdrawals']),
      netDeposits: parseNum(json['netDeposits']),
      lots: parseNum(json['lots']),
      pnl: parseNum(json['pnl']),
    );
  }
}

class IbDashboardKpis {
  final num directReferrals;
  final num totalReferrals;
  final num totalSubIbs;
  final num ftdCount;
  final num ftdPercent;

  IbDashboardKpis({
    this.directReferrals = 0,
    this.totalReferrals = 0,
    this.totalSubIbs = 0,
    this.ftdCount = 0,
    this.ftdPercent = 0,
  });

  factory IbDashboardKpis.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) => val is num ? val : num.tryParse(val?.toString() ?? '') ?? 0;
    return IbDashboardKpis(
      directReferrals: parseNum(json['directReferrals']),
      totalReferrals: parseNum(json['totalReferrals']),
      totalSubIbs: parseNum(json['totalSubIbs']),
      ftdCount: parseNum(json['ftdCount']),
      ftdPercent: parseNum(json['ftdPercent']),
    );
  }
}
