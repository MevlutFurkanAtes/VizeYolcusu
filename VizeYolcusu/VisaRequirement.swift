//
//  VisaRequirement.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 24.04.2026.
//

import Foundation
import Combine

// MARK: - RequirementCategory

enum RequirementCategory: String, CaseIterable, Codable {
    case personal = "Kişisel"
    case work     = "İş"
    case finance  = "Finans"
    case travel   = "Seyahat"
}

// MARK: - VisaRequirement

struct VisaRequirement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: RequirementCategory
    var isMandatory: Bool
    var isCompleted: Bool
    var tip: String?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: RequirementCategory,
        isMandatory: Bool = true,
        isCompleted: Bool = false,
        tip: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.isMandatory = isMandatory
        self.isCompleted = isCompleted
        self.tip = tip
    }
}

// MARK: - VisaData

final class VisaData: ObservableObject {
    @Published var requirements: [VisaRequirement]

    init() {
        self.requirements = VisaData.schengenGermanySample
    }
}

// MARK: - Mock Data: Schengen Vizesi – Almanya (Çalışan)

extension VisaData {
    static let schengenGermanySample: [VisaRequirement] = [

        // MARK: Kişisel
        VisaRequirement(
            title: "Geçerli Pasaport",
            description: "Son 10 yıl içinde düzenlenmiş; vize bitiş tarihinden en az 3 ay sonrasına kadar geçerli pasaport ve biyografik sayfaların fotokopisi.",
            category: .personal,
            isMandatory: true,
            tip: "Pasaportunuzun son geçerlilik tarihinin, seyahat bitiş tarihinden en az 3 ay sonra olduğunu kontrol edin."
        ),
        VisaRequirement(
            title: "Biyometrik Fotoğraf",
            description: "Son 6 ay içinde çekilmiş, ICAO standardına uygun 3,5×4,5 cm, açık arka planlı 2 adet vesikalık fotoğraf.",
            category: .personal,
            isMandatory: true,
            tip: "Gözlük takmayın; nötr yüz ifadesi, tam cepheden ve beyaz/açık gri arka planla çekilmiş olmalıdır."
        ),
        VisaRequirement(
            title: "Tam Vukuatlı Nüfus Kayıt Örneği",
            description: "e-Devlet veya Nüfus Müdürlüğü'nden alınan, son 6 ay içinde düzenlenmiş nüfus kayıt örneği.",
            category: .personal,
            isMandatory: true,
            tip: "e-Devlet'ten alınan barkodlu belge yeterlidir; altı aydan eski olmamalıdır."
        ),
        VisaRequirement(
            title: "Schengen Vize Başvuru Formu",
            description: "Almanya Başkonsolosluğu'nun resmi başvuru formu; eksiksiz doldurulmuş, tarih ve imza atılmış.",
            category: .personal,
            isMandatory: true,
            tip: "Büyükelçiliğin güncel formunu kullanın; tüm alanlar eksiksiz, okunaklı ve imzalı olmalıdır."
        ),
        VisaRequirement(
            title: "Eski Pasaportlar",
            description: "Varsa, önceki Schengen ve diğer yurt dışı vizelerini içeren tüm eski pasaportlar.",
            category: .personal,
            isMandatory: false,
            tip: "Schengen vizesi olan sayfaları görünür bırakarak teslim edin; önceki vizeler güven puanınızı artırır."
        ),

        // MARK: İş
        VisaRequirement(
            title: "İşveren İzin Yazısı",
            description: "Şirket antetli kağıda; görevi, maaşı, izin tarihlerini ve işe kesin dönüş tarihini içeren imzalı ve kaşeli mektup.",
            category: .work,
            isMandatory: true,
            tip: "Mektup şirket antetli kağıda, ıslak imzalı ve kaşeli olmalıdır. İşe dönüş tarihi net biçimde belirtilmelidir."
        ),
        VisaRequirement(
            title: "İş Sözleşmesi",
            description: "Güncel, imzalı ve kaşeli; çalışma süresini ve pozisyonu belgeleyen iş sözleşmesi.",
            category: .work,
            isMandatory: true,
            tip: "Süresiz ya da seyahat tarihini aşan süreli bir sözleşme, güçlü bir başvuru için önemlidir."
        ),
        VisaRequirement(
            title: "SGK Tescil ve Hizmet Dökümü",
            description: "Son 6 aya ait, e-Devlet üzerinden alınan barkodlu SGK hizmet dökümü.",
            category: .work,
            isMandatory: true,
            tip: "e-Devlet'ten alınan barkodlu döküm konsoloslukça kabul edilmektedir; ayrıca ıslak imza gerekmez."
        ),

        // MARK: Finans
        VisaRequirement(
            title: "Son 3 Aylık Maaş Bordrosu",
            description: "Son 3 aya ait, şirket tarafından imzalanmış ve kaşelenmiş maaş bordroları.",
            category: .finance,
            isMandatory: true,
            tip: "Net ve brüt maaş bilgilerini içeren, ıslak imzalı ve kaşeli orijinaller sunun."
        ),
        VisaRequirement(
            title: "Banka Hesap Ekstresi",
            description: "Son 3 aya ait, bankadan kaşe/imzalı günlük bakiye ekstresi (önerilen asgari bakiye: 1.500–2.000 €).",
            category: .finance,
            isMandatory: true,
            tip: "Şube onaylı, ıslak imzalı ekstre alın. İnternet bankacılığı çıktıları genellikle kabul edilmez."
        ),

        // MARK: Seyahat
        VisaRequirement(
            title: "Gidiş-Dönüş Uçak Bileti Rezervasyonu",
            description: "Kesin tarihleri gösteren gidiş-dönüş uçuş rezervasyonu; bilet satın alınması zorunlu değildir.",
            category: .travel,
            isMandatory: true,
            tip: "Rezervasyon yeterlidir; satın alınmış bilet şart değildir. PNR kodu belgede açıkça görünmelidir."
        ),
        VisaRequirement(
            title: "Konaklama Rezervasyonu",
            description: "Seyahatin tüm geceleri için onaylı otel veya konaklama yeri rezervasyonu.",
            category: .travel,
            isMandatory: true,
            tip: "Tüm geceleri kapsayan, iptal edilebilir bir rezervasyon yeterlidir. Airbnb onayı da kabul edilir."
        ),
        VisaRequirement(
            title: "Schengen Seyahat Sağlık Sigortası",
            description: "Tüm Schengen bölgesini kapsayan, minimum 30.000 € teminatlı ve seyahat süresini tam olarak kapsayan poliçe.",
            category: .travel,
            isMandatory: true,
            tip: "Poliçenin tüm Schengen ülkelerini ve tam seyahat süresini kapsadığını, 30.000 € limitini sağladığını doğrulayın."
        )
    ]
}
