import ApiClient from './ApiClient';

class SlaAPI extends ApiClient {
  constructor() {
    super('slas', { accountScoped: true });
  }
}

export default new SlaAPI();
