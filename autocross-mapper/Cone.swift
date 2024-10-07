import CoreLocation

struct Cone: Codable {
    let location: CLLocationCoordinate2D
    let type: ConeType

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case type
    }

    // Manually define an initializer to avoid argument mismatch
    init(location: CLLocationCoordinate2D, type: ConeType) {
        self.location = location
        self.type = type
    }

    // Custom encoding for CLLocationCoordinate2D
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
        try container.encode(type, forKey: .type)
    }

    // Custom decoding for CLLocationCoordinate2D
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        type = try container.decode(ConeType.self, forKey: .type)
    }
}

enum ConeType: String, Codable {
    case starting
    case leftPointer
    case rightPointer
    case single
}

