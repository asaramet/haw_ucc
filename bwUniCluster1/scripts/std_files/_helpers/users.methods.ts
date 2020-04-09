import { uniPrefixes } from '../_helpers/uni_prefixes';
import { months } from '../_helpers/add_data';

interface UserData {
  userID: string,
  email: string,
  costs?: number,
  pcts?: string
}

interface JsonData {
  haw: string,
  data: UserData[]
}

interface UniData {
  prefix: string,
  name: string,
  data?: UserData[]
}

interface MonthlyUniData {
  prefix: string,
  name: string,
  users: number
}

interface MonthlyData {
  month: number,
  data: JsonData[]
}

export interface YearlyUniUsers {
  prefix:string,
  name:string,
  Jan?:number,
  Feb?:number,
  Mar?:number,
  Apr?:number,
  May?:number,
  Jun?:number,
  Jul?:number,
  Aug?:number,
  Set?:number,
  Oct?:number,
  Nov?:number,
  Dec?:number
}

export interface SortedUniUsers {
  users:number,
  month:string
}

export class DataObject  {

  constructor(
    //public data_obj: JsonData[]
    //public dataObj: MonthlyData[]
  ) {}

  public uniDataObj(data_obj:JsonData[], prefix:string):JsonData {
    return data_obj.find ( (element:JsonData) => {
      return element.haw === prefix
    })
  }

  public uniData(data_obj:JsonData[], prefix:string):UserData[]{
    return this.uniDataObj(data_obj, prefix) ? this.uniDataObj(data_obj, prefix).data : undefined
  }

  public nrUsers(data_obj:JsonData[], prefix:string):number {
    return this.uniData(data_obj, prefix) ? this.uniData(data_obj, prefix).length : 0;
  }

  public uniTotalCosts(data_obj:JsonData[], prefix:string):number {
    let tcosts = 0;
    if (this.uniData(data_obj,prefix)) {
      this.uniData(data_obj, prefix).forEach((user_obj:UserData) => {
        tcosts += user_obj.costs
      })
    }
    return tcosts
  }

  public uniDataWithPct(data_obj:JsonData[],prefix:string):UserData[] {
    if (this.uniData(data_obj, prefix)) {
      const tcost:number = this.uniTotalCosts(data_obj, prefix);
      this.uniData(data_obj, prefix).forEach((user_obj:UserData) => {
        user_obj.pcts = (user_obj.costs * 100 / tcost).toFixed(4)
      })
    }
    return this.uniData(data_obj, prefix);
  }

  public getData(data_obj:JsonData[]):UniData[] {
    let allData:UniData[] = []
    uniPrefixes.forEach((prx_elem:UniData) => {
      let push_elem:UniData = { // not to make changed in uniPrefixes
        prefix: prx_elem.prefix,
        name: prx_elem.name
      }
      if (this.uniDataWithPct(data_obj, prx_elem.prefix)) {
        push_elem.data = this.uniDataWithPct(data_obj, prx_elem.prefix)
      }
      allData.push(push_elem);
    })
    return allData
  }

  public tableData(data_obj:JsonData[]):MonthlyUniData[] {
    let generalData:MonthlyUniData[] = [];
    this.getData(data_obj).forEach((element:UniData) => {
      generalData.push({
        prefix: element.prefix,
        name: element.name,
        users: this.nrUsers(data_obj,element.prefix),
      })
    });
    return generalData;
  }

  public yearlyUsers(monthlyDataObject:MonthlyData[]):YearlyUniUsers[] {
    let yearlyData:YearlyUniUsers[] = uniPrefixes;
    monthlyDataObject.forEach((monthly_data:MonthlyData) => {
      const month = monthly_data.month === -1 ? 'Year' : months[monthly_data.month].substring(0,3)
      this.getData(monthly_data.data).forEach((uni_data:UniData) => {
        let obj_to_attach_data_to = yearlyData.find((uni:YearlyUniUsers) => {
          return uni.prefix === uni_data.prefix
        });
        obj_to_attach_data_to[month] = uni_data.data ? uni_data.data.length : 0
      })
    })
    return yearlyData;
  }

  public getChartData(tableData:UserData[]):any[] {
    let chartData:any[] = []
      tableData.forEach((row:UserData) => {
        chartData.push([row.userID, row.costs]);
      })
    return chartData
  }

  public sortedYearlyUsers(monthlyDataObject:MonthlyData[]):SortedUniUsers[] {
    let usersData:any[] = []
    monthlyDataObject.forEach((monthly_data:MonthlyData) => {
      const month = monthly_data.month === -1 ? 'Year' : months[monthly_data.month].substring(0,3)
      this.getData(monthly_data.data).forEach((uni_data:UniData) => {
        const users = uni_data.data ? uni_data.data.length : 0
        if (usersData[uni_data.prefix]) {
          usersData[uni_data.prefix].push({month:month, users: users})
        } else {
          usersData[uni_data.prefix] = [{month:month, users:users}]
        }
      })
    })
    return usersData;
  }
}
