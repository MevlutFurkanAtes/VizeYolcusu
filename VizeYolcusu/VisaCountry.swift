//
//  VisaCountry.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 24.04.2026.
//

import SwiftUI
import Combine

// MARK: - VisaCountry

struct VisaCountry: Identifiable {
    let id: UUID
    let name: String
    let flag: String
    let themeColor: Color
    let gradientColors: [Color]
    let icon: String
    let landmarkIcon: String
    let visaType: String
    var requirements: [VisaRequirement]

    init(
        id: UUID = UUID(),
        name: String,
        flag: String,
        themeColor: Color,
        gradientColors: [Color],
        icon: String,
        landmarkIcon: String,
        visaType: String,
        requirements: [VisaRequirement]
    ) {
        self.id             = id
        self.name           = name
        self.flag           = flag
        self.themeColor     = themeColor
        self.gradientColors = gradientColors
        self.icon           = icon
        self.landmarkIcon   = landmarkIcon
        self.visaType       = visaType
        self.requirements   = requirements
    }
}

// MARK: - CountryStore

final class CountryStore: ObservableObject {
    @Published var countries: [VisaCountry] = CountryStore.sampleCountries
}

// MARK: - Sample Countries

extension CountryStore {
    static let sampleCountries: [VisaCountry] = [
        germany,
        unitedKingdom,
        usa
    ]

    // ─── Almanya (Schengen) ───────────────────────────────────────────────

    static let germany = VisaCountry(
        name: "Almanya",
        flag: "🇩🇪",
        themeColor: Color(red: 0.10, green: 0.18, blue: 0.45),
        gradientColors: [
            Color(red: 0.28, green: 0.18, blue: 0.82),   // İndigo
            Color(red: 0.06, green: 0.38, blue: 0.86)    // Mavi
        ],
        icon: "eurosign.circle.fill",
        landmarkIcon: "building.columns.fill",   // Brandenburg Kapısı
        visaType: "Schengen C Vizesi",
        requirements: [
            VisaRequirement(
                title: "Geçerli Pasaport",
                description: "Vize bitiş tarihinden en az 3 ay sonrasına kadar geçerli pasaport ve biyografik sayfaların fotokopisi.",
                category: .personal,
                isMandatory: true,
                tip: "Son geçerlilik tarihi seyahat bitiş tarihinden en az 3 ay ileride olmalıdır."
            ),
            VisaRequirement(
                title: "Biyometrik Fotoğraf",
                description: "Son 6 ayda çekilmiş, ICAO standardına uygun 3,5×4,5 cm, açık arka planlı 2 adet fotoğraf.",
                category: .personal,
                isMandatory: true,
                tip: "Gözlük takmayın; nötr ifadeyle tam cepheden, beyaz arka planla çekilmiş olmalıdır."
            ),
            VisaRequirement(
                title: "İşveren İzin Yazısı",
                description: "Şirket antetli, görevi, maaşı, izin tarihlerini ve işe dönüş tarihini içeren imzalı kaşeli mektup.",
                category: .work,
                isMandatory: true,
                tip: "Islak imzalı ve kaşeli olmalı; işe dönüş tarihi açıkça belirtilmelidir."
            ),
            VisaRequirement(
                title: "Son 3 Aylık Maaş Bordrosu",
                description: "Son 3 aya ait, şirket tarafından imzalanmış ve kaşelenmiş maaş bordroları.",
                category: .finance,
                isMandatory: true,
                tip: "Net ve brüt maaş bilgilerini içeren, ıslak imzalı orijinaller sunun."
            ),
            VisaRequirement(
                title: "Banka Hesap Ekstresi",
                description: "Son 3 aya ait, bankadan kaşe/imzalı günlük bakiye ekstresi (önerilen asgari: 1.500–2.000 €).",
                category: .finance,
                isMandatory: true,
                tip: "Şube onaylı, ıslak imzalı ekstre alın; internet çıktıları genellikle kabul edilmez."
            ),
            VisaRequirement(
                title: "Schengen Seyahat Sağlık Sigortası",
                description: "Tüm Schengen bölgesini kapsayan, minimum 30.000 € teminatlı poliçe.",
                category: .travel,
                isMandatory: true,
                tip: "Poliçenin tüm Schengen ülkelerini ve tam seyahat süresini kapsadığını doğrulayın."
            )
        ]
    )

    // ─── Birleşik Krallık ─────────────────────────────────────────────────

    static let unitedKingdom = VisaCountry(
        name: "Birleşik Krallık",
        flag: "🇬🇧",
        themeColor: Color(red: 0.65, green: 0.06, blue: 0.06),
        gradientColors: [
            Color(red: 0.75, green: 0.07, blue: 0.17),   // Canlı Kırmızı
            Color(red: 0.38, green: 0.03, blue: 0.08)    // Koyu Kırmızı
        ],
        icon: "sterlingsign.circle.fill",
        landmarkIcon: "crown.fill",              // Kraliyet Tacı
        visaType: "Standart Ziyaretçi Vizesi",
        requirements: [
            VisaRequirement(
                title: "Geçerli Pasaport",
                description: "Seyahat tarihlerini kapsayacak şekilde geçerli pasaport; gerekirse eski pasaportlar da eklenmeli.",
                category: .personal,
                isMandatory: true,
                tip: "UK vizesi pasaportunuzda yer kaplar; boş sayfaların yeterli olduğundan emin olun."
            ),
            VisaRequirement(
                title: "Online Başvuru Formu (UKVI)",
                description: "gov.uk üzerinden doldurulan resmi UK Visas and Immigration başvuru formu ve ödeme makbuzu.",
                category: .personal,
                isMandatory: true,
                tip: "Formu tamamladıktan sonra çıktısını ve başvuru referans numaranızı saklayın."
            ),
            VisaRequirement(
                title: "Finansal Durum Kanıtı",
                description: "Son 6 aya ait banka ekstresi; UK'da yeterli harcamayı karşılayacak bakiyeyi göstermeli.",
                category: .finance,
                isMandatory: true,
                tip: "Ortalama aylık bakiyenin en az 2.500 £ eşdeğeri olması güçlü bir başvuru sağlar."
            ),
            VisaRequirement(
                title: "İşveren Mektubu ve İzin Yazısı",
                description: "Görevi, maaşı, çalışma süresini ve UK seyahati için verilen izni belgeleyen işveren mektubu.",
                category: .work,
                isMandatory: true,
                tip: "Mektup şirket antetli kağıda olmalı; ne kadar süredir çalıştığınızı da belirtmelidir."
            ),
            VisaRequirement(
                title: "Konaklama Kanıtı",
                description: "Tüm geceyi kapsayan otel rezervasyonu veya ev sahibinin davet mektubu ve ikamet belgesi.",
                category: .travel,
                isMandatory: true,
                tip: "Airbnb onayı ya da otel rezervasyonu kabul edilir; iptal edilebilir rezervasyon yeterlidir."
            ),
            VisaRequirement(
                title: "Gidiş-Dönüş Uçuş Rezervasyonu",
                description: "UK'dan çıkışı kanıtlayan bilet veya rezervasyon; kesin tarihleri göstermelidir.",
                category: .travel,
                isMandatory: true,
                tip: "Satın alınmış bilet yerine rezervasyon da genellikle yeterlidir."
            )
        ]
    )

    // ─── Amerika Birleşik Devletleri ──────────────────────────────────────

    static let usa = VisaCountry(
        name: "Amerika Birleşik Devletleri",
        flag: "🇺🇸",
        themeColor: Color(red: 0.05, green: 0.10, blue: 0.35),
        gradientColors: [
            Color(red: 0.10, green: 0.20, blue: 0.65),   // Orta Mavi
            Color(red: 0.03, green: 0.07, blue: 0.30)    // Gece Mavisi
        ],
        icon: "dollarsign.circle.fill",
        landmarkIcon: "globe.americas.fill",     // Amerika Kıtası
        visaType: "B1/B2 Turist & İş Vizesi",
        requirements: [
            VisaRequirement(
                title: "Geçerli Pasaport",
                description: "ABD'ye planladığınız giriş tarihinden itibaren en az 6 ay geçerli pasaport.",
                category: .personal,
                isMandatory: true,
                tip: "Pasaportunuz elektronik çipli (e-pasaport) olmalıdır; aksi hâlde ETA başvurusu yapılamaz."
            ),
            VisaRequirement(
                title: "DS-160 Online Başvuru Formu",
                description: "ABD Dışişleri Bakanlığı'nın resmi portalından (ceac.state.gov) doldurulan nonimmigrant vize formu.",
                category: .personal,
                isMandatory: true,
                tip: "Formu gönderdikten sonra onay sayfasını yazdırın; randevuda barkod gösterilmesi zorunludur."
            ),
            VisaRequirement(
                title: "Vize Başvuru Ücreti (MRV) Makbuzu",
                description: "ABD Büyükelçiliği'ne ödenen 185 USD başvuru ücretinin banka dekontu.",
                category: .finance,
                isMandatory: true,
                tip: "Ödeme için PTT veya büyükelçiliğin anlaşmalı bankalarını kullanın; online ödeme de mümkündür."
            ),
            VisaRequirement(
                title: "Finansal Yeterlilik Belgeleri",
                description: "Son 3–6 aya ait banka ekstresi, maaş bordrosu veya vergi beyannamesi; ABD'deki masrafları karşılayacak gücü kanıtlamalıdır.",
                category: .finance,
                isMandatory: true,
                tip: "Konsolosluk memuru seyahat masraflarını karşılayıp karşılamayacağınızı değerlendirir; güçlü bakiye önemlidir."
            ),
            VisaRequirement(
                title: "Türkiye'ye Bağlılık Kanıtı",
                description: "Taşınmaz tapusu, aile bireyleri, süregelen iş sözleşmesi veya SGK dökümü gibi Türkiye'ye dönüşü güvence altına alan belgeler.",
                category: .work,
                isMandatory: true,
                tip: "B1/B2 başvurularında en sık ret sebebi yeterli bağ kanıtı sunulamamasıdır; birden fazla belge ekleyin."
            ),
            VisaRequirement(
                title: "Seyahat Planı ve Konaklama",
                description: "Gezi güzergâhını, konaklama yerlerini ve aktiviteleri özetleyen belge; otel rezervasyonu veya ev sahibi davet mektubu.",
                category: .travel,
                isMandatory: false,
                tip: "Zorunlu olmasa da hazırlanmış bir seyahat planı mülakat sürecini kolaylaştırır."
            )
        ]
    )
}
