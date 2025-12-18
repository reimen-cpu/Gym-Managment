#include "FinancialEntryRepository.h"
#include <QDateTime>

namespace GymOS::Infrastructure::Repositories {

FinancialEntryRepository::FinancialEntryRepository()
    : m_db(DatabaseManager::instance()) {}

int64_t FinancialEntryRepository::insert(const FinancialEntry &entry) {
  QString sql = R"(
        INSERT INTO financial_entries 
            (entry_type, classification, amount, description, payment_id, entry_date)
        VALUES (?, ?, ?, ?, ?, ?)
    )";

  QVariantList params = {entry.entryTypeId(),
                         entry.classificationId(),
                         entry.amount,
                         entry.description,
                         entry.paymentId.has_value()
                             ? QVariant(entry.paymentId.value())
                             : QVariant(),
                         entry.entryDate.toString(Qt::ISODate)};

  QSqlQuery query = m_db.executeQuery(sql, params);
  return query.lastInsertId().toLongLong();
}

std::vector<FinancialEntry>
FinancialEntryRepository::findByDateRange(const QDate &startDate,
                                          const QDate &endDate) const {
  std::vector<FinancialEntry> entries;

  QSqlQuery query = m_db.executeQuery(
      R"(SELECT * FROM financial_entries 
           WHERE entry_date BETWEEN ? AND ?
           ORDER BY entry_date DESC, created_at DESC)",
      {startDate.toString(Qt::ISODate), endDate.toString(Qt::ISODate)});

  while (query.next()) {
    entries.push_back(mapRow(query));
  }
  return entries;
}

std::vector<FinancialEntry>
FinancialEntryRepository::findLatest(int limit) const {
  std::vector<FinancialEntry> entries;

  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM financial_entries ORDER BY entry_date "
                        "DESC, created_at DESC LIMIT ?",
                        {limit});

  while (query.next()) {
    entries.push_back(mapRow(query));
  }
  return entries;
}

std::vector<FinancialEntry>
FinancialEntryRepository::findByClassification(Classification classification,
                                               const QDate &startDate,
                                               const QDate &endDate) const {
  std::vector<FinancialEntry> entries;
  QString classStr =
      classification == Classification::Income ? "income" : "expense";

  QSqlQuery query = m_db.executeQuery(
      R"(SELECT * FROM financial_entries 
           WHERE classification = ? AND entry_date BETWEEN ? AND ?
           ORDER BY entry_date DESC, created_at DESC)",
      {classStr, startDate.toString(Qt::ISODate),
       endDate.toString(Qt::ISODate)});

  while (query.next()) {
    entries.push_back(mapRow(query));
  }
  return entries;
}

FinancialSummary
FinancialEntryRepository::getSummary(const QDate &startDate,
                                     const QDate &endDate) const {
  FinancialSummary summary;

  QString sql = R"(
        SELECT 
            SUM(CASE WHEN classification = 'income' THEN amount ELSE 0 END) AS total_income,
            SUM(CASE WHEN classification = 'expense' THEN amount ELSE 0 END) AS total_expenses,
            COUNT(*) AS transaction_count
        FROM financial_entries
        WHERE entry_date BETWEEN ? AND ?
    )";

  QSqlQuery query = m_db.executeQuery(
      sql, {startDate.toString(Qt::ISODate), endDate.toString(Qt::ISODate)});

  if (query.next()) {
    summary.totalIncome = query.value("total_income").toDouble();
    summary.totalExpenses = query.value("total_expenses").toDouble();
    summary.transactionCount = query.value("transaction_count").toInt();
  }

  return summary;
}

FinancialSummary FinancialEntryRepository::getTotalSummary() const {
  FinancialSummary summary;

  QString sql = R"(
        SELECT 
            SUM(CASE WHEN classification = 'income' THEN amount ELSE 0 END) AS total_income,
            SUM(CASE WHEN classification = 'expense' THEN amount ELSE 0 END) AS total_expenses,
            COUNT(*) AS transaction_count
        FROM financial_entries
    )";

  QSqlQuery query = m_db.executeQuery(sql);

  if (query.next()) {
    summary.totalIncome = query.value("total_income").toDouble();
    summary.totalExpenses = query.value("total_expenses").toDouble();
    summary.transactionCount = query.value("transaction_count").toInt();
  }

  return summary;
}

std::vector<MonthlyBreakdown>
FinancialEntryRepository::getMonthlyBreakdown(const QDate &startDate,
                                              const QDate &endDate) const {
  std::vector<MonthlyBreakdown> breakdown;

  QString sql = R"(
        SELECT 
            strftime('%Y', entry_date) AS year,
            strftime('%m', entry_date) AS month,
            SUM(CASE WHEN classification = 'income' THEN amount ELSE 0 END) AS income,
            SUM(CASE WHEN classification = 'expense' THEN amount ELSE 0 END) AS expenses
        FROM financial_entries
        WHERE entry_date BETWEEN ? AND ?
        GROUP BY strftime('%Y-%m', entry_date)
        ORDER BY year, month
    )";

  QSqlQuery query = m_db.executeQuery(
      sql, {startDate.toString(Qt::ISODate), endDate.toString(Qt::ISODate)});

  while (query.next()) {
    MonthlyBreakdown mb;
    mb.year = query.value("year").toInt();
    mb.month = query.value("month").toInt();
    mb.income = query.value("income").toDouble();
    mb.expenses = query.value("expenses").toDouble();
    breakdown.push_back(mb);
  }

  return breakdown;
}

FinancialEntry FinancialEntryRepository::mapRow(QSqlQuery &query) const {
  FinancialEntry entry;
  entry.id = query.value("id").toLongLong();
  entry.entryType =
      FinancialEntry::entryTypeFromString(query.value("entry_type").toString());
  entry.classification = FinancialEntry::classificationFromString(
      query.value("classification").toString());
  entry.amount = query.value("amount").toDouble();
  entry.description = query.value("description").toString();

  if (!query.value("payment_id").isNull()) {
    entry.paymentId = query.value("payment_id").toLongLong();
  }

  entry.entryDate =
      QDate::fromString(query.value("entry_date").toString(), Qt::ISODate);
  entry.createdAt =
      QDateTime::fromString(query.value("created_at").toString(), Qt::ISODate);

  return entry;
}

} // namespace GymOS::Infrastructure::Repositories
