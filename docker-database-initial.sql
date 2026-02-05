-- Criação das tabelas para o sistema de gerenciamento de eventos acadêmicos

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE categories
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE locations
(
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    street          VARCHAR(150) NOT NULL,
    number          VARCHAR(20),
    neighborhood    VARCHAR(100) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(2)   NOT NULL,
    zip_code        VARCHAR(10)  NOT NULL,
    reference_point TEXT,
    capacity        INTEGER      NOT NULL
);

CREATE TABLE users
(
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name     VARCHAR(150) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    cpf           VARCHAR(14) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    user_type     VARCHAR(20),
    created_at    TIMESTAMP        DEFAULT NOW()
);

CREATE TABLE organizers
(
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL
);

CREATE TABLE organizer_owners
(
    id           SERIAL PRIMARY KEY,
    organizer_id INTEGER NOT NULL REFERENCES organizers (id),
    user_id      UUID    NOT NULL REFERENCES users (id),
    created_at   TIMESTAMP DEFAULT NOW(),
    UNIQUE (organizer_id, user_id)
);

CREATE TABLE speakers
(
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(150) NOT NULL,
    bio   TEXT,
    email VARCHAR(100)
);

CREATE TABLE speaker_qualifications
(
    id          SERIAL PRIMARY KEY,
    speaker_id  INTEGER      NOT NULL REFERENCES speakers (id),
    title_name  VARCHAR(100) NOT NULL,
    institution VARCHAR(100) NOT NULL
);

CREATE TABLE events
(
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id   INTEGER      NOT NULL REFERENCES organizers (id),
    category_id    INTEGER      NOT NULL REFERENCES categories (id),
    location_id    INTEGER REFERENCES locations (id),

    title          VARCHAR(200) NOT NULL,
    description    TEXT         NOT NULL,
    online_link    VARCHAR(255),

    start_time     TIMESTAMP    NOT NULL,
    end_time       TIMESTAMP    NOT NULL,
    workload_hours INTEGER      NOT NULL,
    max_capacity   INTEGER      NOT NULL,

    status         VARCHAR(20),
    created_at     TIMESTAMP        DEFAULT NOW()
);

CREATE TABLE event_speakers
(
    event_id   UUID    NOT NULL REFERENCES events (id),
    speaker_id INTEGER NOT NULL REFERENCES speakers (id),
    PRIMARY KEY (event_id, speaker_id)
);

CREATE TABLE event_requirements
(
    id          SERIAL PRIMARY KEY,
    event_id    UUID         NOT NULL REFERENCES events (id),
    description VARCHAR(255) NOT NULL
);

CREATE TABLE tags
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE event_tags
(
    event_id UUID    NOT NULL REFERENCES events (id),
    tag_id   INTEGER NOT NULL REFERENCES tags (id),
    PRIMARY KEY (event_id, tag_id)
);

CREATE TABLE registrations
(
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id           UUID NOT NULL REFERENCES users (id),
    event_id          UUID NOT NULL REFERENCES events (id),
    registration_date TIMESTAMP        DEFAULT NOW(),
    attended          BOOLEAN          DEFAULT FALSE,
    status            VARCHAR(20),
    UNIQUE (user_id, event_id)
);

CREATE TABLE certificates
(
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    registration_id UUID NOT NULL UNIQUE REFERENCES registrations (id),
    issued_at       TIMESTAMP        DEFAULT NOW()
);

CREATE TABLE evaluations
(
    id              SERIAL PRIMARY KEY,
    registration_id UUID    NOT NULL UNIQUE REFERENCES registrations (id),
    rating          INTEGER NOT NULL,
    comment         TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- Inserts de exemplo

INSERT INTO public.categories (id, name, description)
VALUES (1, 'Meio Ambiente', 'Abrace uma árvore'),
       (2, 'Educação', 'Letramento Digital para idosos'),
       (3, 'Economia', 'Pague menos impostos');

INSERT INTO public.locations (id, name, street, number, neighborhood, city, state, zip_code, reference_point, capacity)
VALUES (1, 'LACTAL', 'Avenida Bom Pastor', null, 'Boa Vista', 'Garanhuns', 'PE', '55292470', 'UFAPE - Em frente ao ETE',
        120),
       (2, 'BIBLIOTECA ARIANO SUASSUNA', 'Avenida Bom Pastor', null, 'Boa Vista', 'Garanhuns', 'PE', '55292470',
        'UFAPE - Em frente ao ETE', 80),
       (3, 'AUDITORIO PREDIO B (PREDIO DA CORUJA)', 'Avenida Bom Pastor', null, 'Boa Vista', 'Garanhuns', 'PE',
        '55292470', 'UFAPE - Em frente ao ETE', 60);

INSERT INTO public.users (id, full_name, email, cpf, password_hash, user_type, created_at)
VALUES ('9dd22dd9-d9b1-458c-9aea-620275838a46', 'JULIO NETO', 'julio.cerqueira@ufape.edu.br', '11122233344',
        'c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f268646', 'STUDENT', '2026-02-05 02:30:02.144081'),
       ('1f6bc79b-0892-4b41-8dd9-7015006fb0f7', 'PRISCILA VIEIRA', 'priscilla.azevedo@ufape.edu.br', '11122233345',
        '17756315ebd47b7110359fc7b168179bf6f2df3646fcc888bc8aa05c78b38ac1', 'PROFESSOR', '2026-02-05 02:30:02.144081'),
       ('93204139-2295-4f57-955c-14e6584e5971', 'MICHEAL JACKSON', 'rusbe@beat.it', '11122233346',
        '9260f889a03c3de5a806b802afdcca308513328a90c44988955d8dc13dd93504', 'EXTERNAL', '2026-02-05 02:30:02.144081'),
       ('e45c2926-c5b2-4be0-b1fa-721dc27cb642', 'ANONYMOUS', 'example@test.com', '11122233347',
        '89d8b7c49eeda7cf15b25f43b278619a53f876a842b6cc2ed720f3d3294fdc7b', 'ADMIN', '2026-02-05 02:30:02.144081'),
       ('548eb76b-c1d1-42b4-a376-7b47ccaed18a', 'JOSE PORTELA', 'joseportela.silvaneto@ufape.edu.br', '11122233348',
        '7a3180ba33c911df44691db25e5e2c83c5cb0a8d16655291345b8accbddf863d', 'STUDENT', '2026-02-05 02:32:05.015883');

INSERT INTO public.organizers (id, name, contact_email)
VALUES (1, 'CA BCC', 'cabcc@ufape.edu.br'),
       (2, 'DEPARTAMENTO DE PESQUISA EM BANCO DE DADOS', 'dpbd@ufape.edu.br'),
       (3, 'GE JACKSON 5', 'michealjackson@gmail.com');

INSERT INTO public.organizer_owners (id, organizer_id, user_id, created_at)
VALUES (1, 1, '548eb76b-c1d1-42b4-a376-7b47ccaed18a', '2026-02-05 02:38:26.256956'),
       (3, 2, '1f6bc79b-0892-4b41-8dd9-7015006fb0f7', '2026-02-05 02:38:26.256956'),
       (4, 3, '93204139-2295-4f57-955c-14e6584e5971', '2026-02-05 02:38:26.256956');

INSERT INTO public.speakers (id, name, bio, email)
VALUES (1, 'Evaristo de Macedo', 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
        'jogueinosdois@barcareal.com.br'),
       (2, 'Davi Brito', 'Lorem ipsum dolor sit amet consectetur adipiscing elit.', 'emaildigue@gmail.com'),
       (3, 'Faustão', 'Lorem ipsum dolor sit amet consectetur adipiscing elit.', 'oloco@meu.com.br');

INSERT INTO public.speaker_qualifications (id, speaker_id, title_name, institution)
VALUES (1, 2, 'EX BBB', 'GLOBO'),
       (2, 3, 'JORNALISTA', 'BAND'),
       (3, 1, 'EX TECNICO E EX JOGADOR', 'BARCELONA / REAL MADIRD');

INSERT INTO public.events (id, organizer_id, category_id, location_id, title, description, online_link, start_time,
                           end_time, workload_hours, max_capacity, status, created_at)
VALUES ('31616ab5-d53d-498b-927b-01b571267b28', 1, 2, 3, 'EVARISTO: UM HOMEM, UMA MÁQUINA!',
        'Lorem ipsum dolor sit amet consectetur adipiscing elit.', 'https://meet.google.com/abc-def-ghi',
        '2026-02-04 23:53:28.000000', '2026-02-05 23:53:49.000000', 6, 50, 'FINISHED', '2026-02-05 03:02:44.736831'),
       ('511bb824-c54e-45f7-af56-8589f8f634be', 3, 1, 1, 'FAUSTÃO E SEUS TRANSPLANTES: UMA NOVELA QUE NEM SEI...',
        'Lorem ipsum dolor sit amet consectetur adipiscing elit.', 'https://meet.google.com/ajk-def-ghi',
        '2026-02-10 23:57:57.000000', '2026-02-11 23:57:57.000000', 12, 120, 'PUBLISHED', '2026-02-05 03:02:44.736831'),
       ('cb7ad1a4-dc40-4f77-a144-1208085ff318', 2, 3, 2, 'DO LIXO AO LUXO: COMO GANHEI O BBB E FIZ O $$$ RENDER',
        'Lorem ipsum dolor sit amet consectetur adipiscing elit.', 'https://meet.google.com/ajk-def-XYZ',
        '2026-02-21 00:01:28.000000', '2026-02-21 00:01:28.000000', 3, 30, 'DRAFT', '2026-02-05 03:02:44.736831');

INSERT INTO public.event_speakers (event_id, speaker_id)
VALUES ('31616ab5-d53d-498b-927b-01b571267b28', 1),
       ('511bb824-c54e-45f7-af56-8589f8f634be', 3),
       ('cb7ad1a4-dc40-4f77-a144-1208085ff318', 2);

INSERT INTO public.event_requirements (id, event_id, description)
VALUES (1, '31616ab5-d53d-498b-927b-01b571267b28', 'SABER FUTEBOL'),
       (2, '31616ab5-d53d-498b-927b-01b571267b28', 'SABER JOGAR'),
       (3, '31616ab5-d53d-498b-927b-01b571267b28', 'NAO SER UM MERDA');

INSERT INTO public.tags (id, name)
VALUES (1, 'FUTEBOL'),
       (2, 'REALITY SHOW'),
       (3, 'SAUDE');

INSERT INTO public.event_tags (event_id, tag_id)
VALUES ('31616ab5-d53d-498b-927b-01b571267b28', 1),
       ('511bb824-c54e-45f7-af56-8589f8f634be', 3),
       ('cb7ad1a4-dc40-4f77-a144-1208085ff318', 2);

INSERT INTO public.registrations (id, user_id, event_id, registration_date, attended, status)
VALUES ('93f9d933-3ed6-4109-8774-ee356f9b7451', '9dd22dd9-d9b1-458c-9aea-620275838a46',
        '31616ab5-d53d-498b-927b-01b571267b28', '2026-02-01 00:16:23.000000', true, 'CONFIRMED');

INSERT INTO public.certificates (id, registration_id, issued_at)
VALUES ('ab152d47-0dfc-4558-9f6b-35d291d0a9fe', '93f9d933-3ed6-4109-8774-ee356f9b7451', '2026-02-05 03:18:24.002754');

INSERT INTO public.evaluations (id, registration_id, rating, comment, created_at)
VALUES (1, '93f9d933-3ed6-4109-8774-ee356f9b7451', 5,
        'CONHECI EVARISTO PELO YOUTUBE. SUA TRAJETORIA DE VIDA E FANTASTICA', '2026-02-05 03:19:52.964390');
