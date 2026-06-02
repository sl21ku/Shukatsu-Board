import SwiftUI

struct CompanyCompactRow: View {
    let company: Company

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(company.name)
                    .font(.headline)
                Spacer()
                StatusBadge(status: company.status)
            }

            HStack(spacing: 12) {
                if let industry = company.industry, !industry.isEmpty {
                    Label(industry, systemImage: "tag")
                }

                Label("志望度 \(company.priority)", systemImage: "star")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
