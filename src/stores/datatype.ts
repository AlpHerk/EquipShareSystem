 
export interface User {
    id?: string
    addres?: string
    createTime?: string

    name: string 
    avatar: string
    email: string
    tellphone: string
    organization: string

    ownedEquipt?: Object
    rentedEquipt?: Object

}

export interface Equipment { 
    id?: string 
    owner?: string
    createdTime?: string
    isFrozen?: boolean

    name: string
    category: string
    descLink: string
    imagesLink: string
    unitPrice: string
    deposit: string

    useCnt?: UseCnt
    occupyPeriod?: OccupyPeriod[]

    // 额外属性，且以太坊无 
    occupytype?: OccupyType
}

export interface LeasePact {
    id: string
    equipmentId: string
    equipmentName: string
    owner: string
    renter: string
    price: Price
    period: Period
    stepsTime: StepsTime
}





export enum OccupyType {
    OPEN,
    LENT,
    MAINTAIN,
    FROZEN
}

export interface OccupyPeriod {
    startTime: number
    endTime: number
    userid: number
    occupyType: OccupyType
}

export interface UseCnt {
    lent: string
    maintain: string
    frozen: string
}






export interface Period {
    startTime: number
    endTime: number
    userid: number
    occupyType: OccupyType
}

export interface Price {
    unitPrice: string    
    totalPrice: string   
    deposit: string   
    isPaid: boolean   
    isEquipmentReturned: boolean   
}

export interface StepsTime { 
    CREATED: string
    CANCEL: string
    APPROVED: string
    REJECTED: string
    COMPLETED: string
}


export interface AccountInfo {
    name:    string
    type:    string 
    address: string
    style1: { 
        visibility: string,
        display: string
    }  
    style2: { 
        visibility: string,
        display: string
    }  
}